package Comainu::Method::Plain2bnstout;

use strict;
use warnings;
use utf8;
use parent 'Comainu::Method';
use File::Basename qw(basename);
use Config;

use Comainu::Method::Kc2bnstout;

sub new {
    my ($class, %args) = @_;
    bless {
        args_num => 4,
        comainu  => delete $args{comainu},
        %args
    }, $class;
}

# 平文からの文節境界解析
sub usage {
    my $self = shift;
    printf("COMAINU-METHOD: plain2bnstout\n");
    printf("  Usage: %s plain2bnstout <test-text> <bnst-model-file> <out-dir>\n", $0);
    printf("    This command analyzes <test-text> with MeCab and <bnst-model-file>.\n");
    printf("    The result is put into <out-dir>.\n");
    printf("\n");
    printf("  ex.)\n");
    printf("  \$ perl ./script/comainu.pl plain2bnstout sample/plain/sample.txt train/bnst.model out\n");
    printf("    -> out/sample.txt.bout\n");
    printf("\n");
}

sub run {
    my ($self, $test_file, $bnstmodel, $save_dir) = @_;

    $self->before_analyze({
        dir => $save_dir, bnstmodel => $bnstmodel, args_num => scalar @_
    });

    $self->analyze($test_file, $bnstmodel, $save_dir);

    return 0;
}

sub analyze {
    my ($self, $test_file, $bnstmodel, $save_dir) = @_;

    my $tmp_dir = $self->comainu->{"comainu-temp"};
    my $basename = basename($test_file);
    my $mecab_file   = $tmp_dir  . "/" . $basename . ".mecab";
    my $kc_file      = $tmp_dir  . "/" . $basename . ".KC";
    my $kc_bout_file = $tmp_dir  . "/" . $basename . ".KC.bout";
    my $bout_file    = $save_dir . "/" . $basename . ".bout";

    $self->comainu->plain2mecab_file($test_file, $mecab_file);
    $self->comainu->mecab2kc_file($mecab_file, $kc_file);
    my $kc2bnstout = Comainu::Method::Kc2bnstout->new(comainu => $self->comainu);
    $kc2bnstout->run($kc_file, $bnstmodel, $tmp_dir);
    $self->comainu->merge_mecab_with_kc_bout_file($mecab_file, $kc_bout_file, $bout_file);

    unless ( $self->comainu->{debug} ) {
        do { unlink $_ if -f $_; } for ($mecab_file, $kc_bout_file);
    }

    return 0;
}


1;