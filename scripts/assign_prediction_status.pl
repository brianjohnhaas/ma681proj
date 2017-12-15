#!/usr/bin/env perl

use strict;
use warnings;

my $usage = "usage: $0  pred_file acc_col padj_col\n\n";

my $pred_file = $ARGV[0] or die $usage;
my $acc_col = $ARGV[1];
unless (defined $acc_col) { die $usage; }

my $padj_col = $ARGV[2] or die $usage;

my $TP_file = "/Users/bhaas/BU/MA681_stats/ClassProject/data/CellLines/define_truth_set/TP.list";
my $TN_file = "/Users/bhaas/BU/MA681_stats/ClassProject/data/CellLines/define_truth_set/TN.list";



main: {

    my %TPs = &parse_accs($TP_file);
    my %TNs = &parse_accs($TN_file);

    my $total_truth = scalar(keys %TPs);
    my $num_TP = 0;
    my $num_FP = 0;
    my $num_TN = 0;
    
    my $num_preds = 0;
    
    open(my $fh, $pred_file) or die "Error, cannot open file: $pred_file";
    my $header = <$fh>;
    chomp $header;
    print join("\t", $header, "class", "TP_rate", "FP_rate") . "\n";
    
    my @results;
    while (<$fh>) {
        chomp;
        my @x = split(/\t/);
        push (@results, \@x);
    }
    close $fh;

    @results = sort { $a->[$padj_col] <=> $b->[$padj_col] } @results;

    my $total_num_genes = 21711; # from the all.genes file

    my $num_TNs = $total_num_genes - $total_truth;
    
    foreach my $result (@results) {
        my @x = @$result;
        
        my $acc = $x[$acc_col];
        my $pval = $x[$padj_col];
        
        my $class;
        
        if ($TPs{$acc}) {
            $class = "TP";
            $num_TP++;
        }
        elsif ($TNs{$acc}) {
            $class = "FP";
            $num_FP++;
        }
        else {
            $class = "NA";
        }
        
        
        my $TP_rate = $num_TP / $total_truth;
        
        my $FP_rate = $num_FP / $num_TNs;
        
        push (@x, $class, $TP_rate, $FP_rate);
        print join("\t", @x) . "\n";
    }
    close $fh;
    

    exit(0);
    
}

####
sub parse_accs {
    my ($file) = @_;

    my %accs;
    
    open(my $fh, $file) or die "Error, cannot open file: $file";
    while (<$fh>) {
        chomp;
        my $acc = $_;
            
        $accs{$acc} = 1;
    }
    close $fh;

    return(%accs);
}
