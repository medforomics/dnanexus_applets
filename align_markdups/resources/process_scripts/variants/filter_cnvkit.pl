#!/usr/bin/perl -w
#parse_cnvkit_table.pl

my $refdir = '/project/shared/bicf_workflow_ref/human/GRCh38/';
open OM, "<$refdir\/clinseq_prj/panel1410.genelist.txt" or die $!;
while (my $line = <OM>) {
  chomp($line);
  $keep{$line} = 1;
}

open ENT_ENS, "<$refdir/../gene2ensembl.human.txt" or die $!;
my %entrez;
my $ent_header = <ENT_ENS>;
while (my $line = <ENT_ENS>){
  chomp $line;
  my @row = split(/\t/, $line);
  $entrez{$row[2]}=$row[1];
}
close ENT_ENS;
open ENT_SYM, "<$refdir/../gene_info.human.txt" or die $!;
$ent_header = <ENT_SYM>;
while (my $line = <ENT_SYM>){
  chomp $line;
  my @row = split(/\t/, $line);
  $entrez{$row[2]}=$row[1];
}
close ENT_SYM;

my $file = shift @ARGV;
my $sname = (split(/\./,(split(/\//,$file))[-1]))[0];
my $prefix = (split(/\./,$file))[0];
my %cyto;
open CYTO, "<$prefix\.cytoband.bed" or die $!;
while (my $line = <CYTO>) {
    chomp($line);
    my ($chrom,$start,$end,$band) = split(/\t/,$line);
    my $key = $chrom.":".$start."-".$end;
    $band =~ m/^(\w)(.+)/;
    next unless ($1 && $2);
    push @{$cyto{$key}{$1}},$2;
}

open OUT, ">$prefix\.cnvcalls.txt" or die $!;
open OUT2, ">$prefix\.cnv.answer.txt" or die $!;
open OUT3, ">$prefix\.answerplot.cns" or die $!;
open BIO, ">$prefix\.data_cna_discrete.cbioportal.txt" or die $!;
open BIO2, ">$prefix\.data_cna_continuous.cbioportal.txt" or die $!;

print OUT join("\t","Gene","Chromosome","Start","End","Abberation Type","CN","Score"),"\n";
print OUT3 join("\t","Chromosome","Start","End","Log2","CN"),"\n";
print OUT2 join("\t","Gene","Chromosome","Start","End","Abberation Type","CN","Score","CytoBand"),"\n";
print BIO join("\t","Hugo_Symbol","Entrez_Gene_Id",$sname),"\n";
print BIO2 join("\t","Hugo_Symbol","Entrez_Gene_Id",$sname),"\n";

open CNR, "<$prefix\.cnr" or die $!;
open CNRO, ">$prefix\.answerplot.cnr" or die $!;
print CNRO join("\t","Gene","Chromosome","Start","End","Log2","Depth","Weight"),"\n";
my $header = <CNR>;
while (my $line = <CNR>) {
    chomp($line);
    my ($chr,$start,$end,$geneids,$log2,$depth,$weight) = split(/\t/,$line);
    my $key = $chr.":".$start."-".$end;
    my %genes;
    if ($geneids =~ m/ensembl_gn/g) {
	my @ids = split(/;|,/,$geneids);
	foreach my $gid (@ids) {
	    my ($key,$value) = split(/=/,$gid);
	    if ($key eq 'ensembl_gn' || $key eq 'identifier') {
		$genes{$value} = 1 if $keep{$value};
	    }
	}
    }elsif ($geneids =~ m/:/) {
	my ($gene,$chr,$pos) = split(/:/,$geneids);
	$genes{$gene} = 1;
    }else {
	my @ids = split(/,/,$geneids);
	foreach my $gid (@ids) {
	    my ($gene,$trxid,$exonnum,$strand) = split(/\|/,$gid);
	    $genes{$gene} = 1 if $keep{$gene};
	}
    }
    foreach $gene (keys %genes) {
	print CNRO join("\t",$gene,$chr,$start,$end,$log2,$depth,$weight),"\n"; 
    }
}

open IN, "<$file" or die $!;
$header = <IN>;
while (my $line = <IN>) {
    chomp($line);
    my ($chr,$start,$end,$geneids,$log2,$cn,$depth,
	$probes,$weight) = split(/\t/,$line);
    next if ($chr eq 'chrX' && $cn == 1);
    my $key = $chr.":".$start."-".$end;
    my %genes;
    if ($geneids =~ m/ensembl_gn/g) {
	my @ids = split(/;|,/,$geneids);
	foreach my $gid (@ids) {
	    my ($key,$value) = split(/=/,$gid);
	    if ($key eq 'ensembl_gn' || $key eq 'identifier') {
		$genes{$value} = 1 if $keep{$value};
	    }
	}
    }elsif ($geneids =~ m/:/) {
	my ($gene,$chr,$pos) = split(/:/,$geneids);
	$genes{$gene} = 1;
    }else {
	my @ids = split(/,/,$geneids);
	foreach my $gid (@ids) {
	    my ($gene,$trxid,$exonnum,$strand) = split(/\|/,$gid);
	    $genes{$gene} = 1 if $keep{$gene};
	}
    }
    my $len = sprintf("%.1f",($end-$start)/1000);
    print OUT3 join("\t",$chr,$start,$end,$log2,$cn),"\n";
    next if ($cn == 2) || scalar(keys %genes) < 1;
    my $abtype = 'amplification';
    $abtype = 'loss' if ($cn < 2);
    $abtype = 'gain' if ($cn > 2 && $cn < 6);
    foreach $gene (keys %genes) {
	$cn_cbio = $cn -2;
	$cn_cbio = 2 if ($cn > 4);
	print BIO join("\t",$gene,$entrez{$gene},$cn_cbio),"\n";
        print BIO2 join("\t",$gene,$entrez{$gene},$log2),"\n";
	my @cytoband;
	if (@{$cyto{$key}{'p'}}) {
	  @nums = sort {$b <=> $a} @{$cyto{$key}{'p'}};
	  push @cytoband, 'p'.$nums[0],'p'.$nums[-1];
	} if (@{$cyto{$key}{'q'}}) {
	  @nums = sort {$a <=> $b} @{$cyto{$key}{'q'}};
	  push @cytoband, 'q'.$nums[0],'q'.$nums[-1];
	} 
	if ($cytoband[0] eq $cytoband[-1]) {
	  $cband = $cytoband[0];
	}else {
	  $cband = join("-",$cytoband[0],$cytoband[-1]);
	}
	    print OUT2 join("\t",$gene,$chr,$start,$end,$abtype,$cn,$weight,$cband),"\n";
	    print OUT join("\t",$gene,$chr,$start,$end,$abtype,$cn,$weight),"\n";
	  }
      }
close IN;
close OUT;
close BIO;
close BIO2;
