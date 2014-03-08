package Comainu::Method::Bccwj2longout;

use strict;
use warnings;
use utf8;
use parent 'Comainu::Method';
use File::Basename qw(basename);
use Config;

use Comainu::Format;
use Comainu::Method::Kc2longout;

# 長単位解析 BCCWJ
# 解析対象BCCWJファイル、モデルファイルの３つを用いて
# 解析対象BCCWJファイルに長単位情報を付与する。
sub usage {
    my $self = shift;
    printf("COMAINU-METHOD: bccwj2longout\n");
    printf("  Usage: %s bccwj2longout <test-bccwj> <out-dir>\n", $0);
    printf("    This command analyzes <test-bccwj> with <long-model-file>.\n");
    printf("    The result is put into <out-dir>.\n");
    printf("\n");
    printf("  ex.)\n");
    printf("  \$ perl ./script/comainu.pl bccwj2longout sample/sample.bccwj.txt out\n");
    printf("    -> out/sample.bccwj.txt.lout\n");
    printf("  \$ perl ./script/comainu.pl bccwj2longout --luwmodel-type=SVM --luwmodel=train/SVM/train.KC.model sample/sample.bccwj.txt out\n");
    printf("    -> out/sample.bccwj.txt.lout\n");
    printf("\n");
}

sub run {
    my ($self, $test_bccwj, $save_dir) = @_;

    $self->before_analyze({
        dir => $save_dir, luwmodel  => $self->{luwmodel}
    });

    $self->analyze_files($test_bccwj, $save_dir);

    return 0;
}

sub analyze {
    my ($self, $test_bccwj, $save_dir) = @_;

    my $tmp_dir = $self->{"comainu-temp"};
    my $basename = basename($test_bccwj);
    my $tmp_test_bccwj =  $tmp_dir . "/" . $basename;
    Comainu::Format->format_inputdata({
        input_file       => $test_bccwj,
        input_type       => 'input-bccwj',
        output_file      => $tmp_test_bccwj,
        output_type      => 'bccwj',
        data_format_file => $self->{data_format},
    });

    my $kc_file         = $tmp_dir  . "/" . $basename . ".KC";
    my $kc_lout_file    = $tmp_dir  . "/" . $basename . ".KC.lout";

    Comainu::Format->bccwj2kc_file($tmp_test_bccwj, $kc_file, $self->{boundary});
    my $kc2longout = Comainu::Method::Kc2longout->new(%$self);
    $kc2longout->analyze($kc_file, $tmp_dir);
    my $buff = Comainu::Format->merge_bccwj_with_kc_lout_file($tmp_test_bccwj, $kc_lout_file, $self->{boundary});
    $self->output_result($buff, $save_dir, $basename . ".lout");
    undef $buff;

    unless ( $self->{debug} ) {
        do { unlink $_ if -f $_; } for ($kc_lout_file, $tmp_test_bccwj);
    }

    return 0;
}


1;
