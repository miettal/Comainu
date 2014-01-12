package t::Comainu::Method::Kc2longmodel;
use strict;
use warnings;
use utf8;

use lib 'lib', 't/lib';
use Test::Comainu;

use parent 'Test::Class';
use Test::More;
use Test::Mock::Guard;

sub _use_ok : Test(startup => 1) {
    use_ok 'Comainu::Method::Kc2longmodel';
}

# sub run : Tests {};

sub make_luw_traindata : Test(14) {
    my $buff = <<DATA;
詰め ツメル 詰める 動詞-一般 下一段-マ行 連用形-一般 ツメ ツメル 詰める 詰め * * 和 名詞-普通名詞-一般 * * ツメショウギ 詰め将棋 詰め将棋
将棋 ショウギ 将棋 名詞-普通名詞-一般 * * ショウギ ショウギ 将棋 将棋 * * 漢 * * * * * *
の ノ の 助詞-格助詞 * * ノ ノ の の * * 和 助詞-格助詞 * * ノ の の
*B
本 ホン 本 名詞-普通名詞-一般 * * ホン ホン 本 本 * * 漢 名詞-普通名詞-一般 * * ホン 本 本
を ヲ を 助詞-格助詞 * * ヲ ヲ を を * * 和 助詞-格助詞 * * ヲ を を
*B
買っ カウ 買う 動詞-一般 五段-ワア行-一般 連用形-促音便 カッ カウ 買う 買っ * * 和 動詞-一般 五段-ワア行-一般 連用形-促音便 カウ 買う 買っ
て テ て 助詞-接続助詞 * * テ テ て て * * 和 助詞-接続助詞 * * テ て て
*B
き クル 来る 動詞-非自立可能 カ行変格 連用形-一般 キ クル 来る 来 * * 和 動詞-一般 カ行変格 連用形-一般 クル 来る き
まし マス ます 助動詞 助動詞-マス 連用形-一般 マシ マス ます まし * * 和 助動詞 助動詞-マス 連用形-一般 マス ます まし
た タ た 助動詞 助動詞-タ 終止形-一般 タ タ た た * * 和 助動詞 助動詞-タ 終止形-一般 タ た た
。 * 。 補助記号-句点 * * * * 。 。 * * 記号 補助記号-句点 * * * 。 。
DATA

    my @bip_data;
    my $g = mock_guard(
        'Comainu::Feature' => {
            read_from_file => sub { $buff }
        },
        'Comainu::BIProcessor' => {
            write_to_file => sub {
                my ($file, $data) = @_;
                push @bip_data, $data;
            },
        },
    );
    my $kc2_data = '';
    my $g2 = guard_write_to_file('Comainu::Method::Kc2longmodel', \$kc2_data);

    my $kc2longmodel = Comainu::Method::Kc2longmodel->new;
    $kc2longmodel->make_luw_traindata('t/sample/test.KC', 't/sample/test.KC.svmin', 't/sample');
    my @lines = split /\n/, $kc2_data;

    is $lines[0], "詰め ツメル 詰める 動詞-一般 下一段-マ行 連用形-一般 * * 和 動詞 一般 * * 下一段 マ行 * 連用形 一般 * B";
    is $lines[1], "将棋 ショウギ 将棋 名詞-普通名詞-一般 * * * * 漢 名詞 普通名詞 一般 * * * * * * * Ia";
    is $lines[2], "の ノ の 助詞-格助詞 * * * * 和 助詞 格助詞 * * * * * * * * Ba";
    is $lines[3], "本 ホン 本 名詞-普通名詞-一般 * * * * 漢 名詞 普通名詞 一般 * * * * * * * Ba";
    is $lines[4], "を ヲ を 助詞-格助詞 * * * * 和 助詞 格助詞 * * * * * * * * Ba";
    is $lines[5], "買っ カウ 買う 動詞-一般 五段-ワア行-一般 連用形-促音便 * * 和 動詞 一般 * * 五段 ワア行 一般 連用形 促音便 * Ba";
    is $lines[6], "て テ て 助詞-接続助詞 * * * * 和 助詞 接続助詞 * * * * * * * * Ba";
    is $lines[7], "き クル 来る 動詞-非自立可能 カ行変格 連用形-一般 * * 和 動詞 非自立可能 * * カ行変格 * * 連用形 一般 * B";
    is $lines[8], "まし マス ます 助動詞 助動詞-マス 連用形-一般 * * 和 助動詞 * * * 助動詞 マス * 連用形 一般 * Ba";
    is $lines[9], "た タ た 助動詞 助動詞-タ 終止形-一般 * * 和 助動詞 * * * 助動詞 タ * 終止形 一般 * Ba";
    is $lines[10], "。 * 。 補助記号-句点 * * * * 記号 補助記号 句点 * * * * * * * * Ba";


    my $pos_gold = <<POS;
来る て テ て 助詞-接続助詞 助詞 接続助詞 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * て テ て 助詞-接続助詞 助詞 接続助詞 * * * * * * * * * * き クル 来る 動詞-非自立可能 動詞 非自立可能 * * カ行変格 カ行変格 * * 連用形-一般 連用形 一般 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * き クル 来る 動詞-非自立可能 動詞 非自立可能 * * カ行変格 カ行変格 * * 連用形-一般 連用形 一般 * まし マス ます 助動詞 助動詞 * * * 助動詞-マス 助動詞 マス * 連用形-一般 連用形 一般 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * まし マス ます 助動詞 助動詞 * * * 助動詞-マス 助動詞 マス * 連用形-一般 連用形 一般 * H080
ている 持っ モツ 持つ 動詞-一般 動詞 一般 * * 五段-タ行 五段 タ行 * 連用形-促音便 連用形 促音便 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 持っ モツ 持つ 動詞-一般 動詞 一般 * * 五段-タ行 五段 タ行 * 連用形-促音便 連用形 促音便 * て テ て 助詞-接続助詞 助詞 接続助詞 * * * * * * * * * * い イル 居る 動詞-非自立可能 動詞 非自立可能 * * 上一段-ア行 上一段 ア行 * 連用形-一般 連用形 一般 * て テ て 助詞-接続助詞 助詞 接続助詞 * * * * * * * * * * い イル 居る 動詞-非自立可能 動詞 非自立可能 * * 上一段-ア行 上一段 ア行 * 連用形-一般 連用形 一般 * ませ マス ます 助動詞 助動詞 * * * 助動詞-マス 助動詞 マス * 未然形-一般 未然形 一般 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * ませ マス ます 助動詞 助動詞 * * * 助動詞-マス 助動詞 マス * 未然形-一般 未然形 一般 * H100
フリー 使える ツカウ 使う 動詞-一般 動詞 一般 * * 下一段-ア行 下一段 ア行 * 連体形-一般 連体形 一般 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 使える ツカウ 使う 動詞-一般 動詞 一般 * * 下一段-ア行 下一段 ア行 * 連体形-一般 連体形 一般 * フリー フリー フリー 名詞-普通名詞-形状詞可能 名詞 普通名詞 形状詞可能 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * フリー フリー フリー 名詞-普通名詞-形状詞可能 名詞 普通名詞 形状詞可能 * * * * * * * * * の ノ の 助詞-格助詞 助詞 格助詞 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * の ノ の 助詞-格助詞 助詞 格助詞 * * * * * * * * * * H000
ソフト の ノ の 助詞-格助詞 助詞 格助詞 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * の ノ の 助詞-格助詞 助詞 格助詞 * * * * * * * * * * ソフト ソフト ソフト 名詞-普通名詞-形状詞可能 名詞 普通名詞 形状詞可能 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * ソフト ソフト ソフト 名詞-普通名詞-形状詞可能 名詞 普通名詞 形状詞可能 * * * * * * * * * って ッテ って 助詞-副助詞 助詞 副助詞 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * って ッテ って 助詞-副助詞 助詞 副助詞 * * * * * * * * * * H000
有る って ッテ って 助詞-副助詞 助詞 副助詞 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * って ッテ って 助詞-副助詞 助詞 副助詞 * * * * * * * * * * あり アル 有る 動詞-非自立可能 動詞 非自立可能 * * 五段-ラ行 五段 ラ行 * 連用形-一般 連用形 一般 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * あり アル 有る 動詞-非自立可能 動詞 非自立可能 * * 五段-ラ行 五段 ラ行 * 連用形-一般 連用形 一般 * ませ マス ます 助動詞 助動詞 * * * 助動詞-マス 助動詞 マス * 未然形-一般 未然形 一般 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * ませ マス ます 助動詞 助動詞 * * * 助動詞-マス 助動詞 マス * 未然形-一般 未然形 一般 * H080
無い やっぱり ヤハリ 矢張り 副詞 副詞 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * やっぱり ヤハリ 矢張り 副詞 副詞 * * * * * * * * * * * ない ナイ 無い 形容詞-非自立可能 形容詞 非自立可能 * * 形容詞 形容詞 * * 連体形-一般 連体形 一般 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * ない ナイ 無い 形容詞-非自立可能 形容詞 非自立可能 * * 形容詞 形容詞 * * 連体形-一般 連体形 一般 * の ノ の 助詞-準体助詞 助詞 準体助詞 * * * * * * * * * * でしょう デス です 助動詞 助動詞 * * * 助動詞-デス 助動詞 デス * 意志推量形 意志推量形 * * の ノ の 助詞-準体助詞 助詞 準体助詞 * * * * * * * * * * でしょう デス です 助動詞 助動詞 * * * 助動詞-デス 助動詞 デス * 意志推量形 意志推量形 * * H090

POS

    my $cType_gold = <<CTYPE;
来る て テ て 助詞-接続助詞 助詞 接続助詞 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * て テ て 助詞-接続助詞 助詞 接続助詞 * * * * * * * * * * き クル 来る 動詞-非自立可能 動詞 非自立可能 * * カ行変格 カ行変格 * * 連用形-一般 連用形 一般 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * き クル 来る 動詞-非自立可能 動詞 非自立可能 * * カ行変格 カ行変格 * * 連用形-一般 連用形 一般 * まし マス ます 助動詞 助動詞 * * * 助動詞-マス 助動詞 マス * 連用形-一般 連用形 一般 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * まし マス ます 助動詞 助動詞 * * * 助動詞-マス 助動詞 マス * 連用形-一般 連用形 一般 * H080 K1050
ている 持っ モツ 持つ 動詞-一般 動詞 一般 * * 五段-タ行 五段 タ行 * 連用形-促音便 連用形 促音便 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 持っ モツ 持つ 動詞-一般 動詞 一般 * * 五段-タ行 五段 タ行 * 連用形-促音便 連用形 促音便 * て テ て 助詞-接続助詞 助詞 接続助詞 * * * * * * * * * * い イル 居る 動詞-非自立可能 動詞 非自立可能 * * 上一段-ア行 上一段 ア行 * 連用形-一般 連用形 一般 * て テ て 助詞-接続助詞 助詞 接続助詞 * * * * * * * * * * い イル 居る 動詞-非自立可能 動詞 非自立可能 * * 上一段-ア行 上一段 ア行 * 連用形-一般 連用形 一般 * ませ マス ます 助動詞 助動詞 * * * 助動詞-マス 助動詞 マス * 未然形-一般 未然形 一般 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * ませ マス ます 助動詞 助動詞 * * * 助動詞-マス 助動詞 マス * 未然形-一般 未然形 一般 * H100 K1020
フリー 使える ツカウ 使う 動詞-一般 動詞 一般 * * 下一段-ア行 下一段 ア行 * 連体形-一般 連体形 一般 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 使える ツカウ 使う 動詞-一般 動詞 一般 * * 下一段-ア行 下一段 ア行 * 連体形-一般 連体形 一般 * フリー フリー フリー 名詞-普通名詞-形状詞可能 名詞 普通名詞 形状詞可能 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * フリー フリー フリー 名詞-普通名詞-形状詞可能 名詞 普通名詞 形状詞可能 * * * * * * * * * の ノ の 助詞-格助詞 助詞 格助詞 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * の ノ の 助詞-格助詞 助詞 格助詞 * * * * * * * * * * H000 K1999
ソフト の ノ の 助詞-格助詞 助詞 格助詞 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * の ノ の 助詞-格助詞 助詞 格助詞 * * * * * * * * * * ソフト ソフト ソフト 名詞-普通名詞-形状詞可能 名詞 普通名詞 形状詞可能 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * ソフト ソフト ソフト 名詞-普通名詞-形状詞可能 名詞 普通名詞 形状詞可能 * * * * * * * * * って ッテ って 助詞-副助詞 助詞 副助詞 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * って ッテ って 助詞-副助詞 助詞 副助詞 * * * * * * * * * * H000 K1999
有る って ッテ って 助詞-副助詞 助詞 副助詞 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * って ッテ って 助詞-副助詞 助詞 副助詞 * * * * * * * * * * あり アル 有る 動詞-非自立可能 動詞 非自立可能 * * 五段-ラ行 五段 ラ行 * 連用形-一般 連用形 一般 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * あり アル 有る 動詞-非自立可能 動詞 非自立可能 * * 五段-ラ行 五段 ラ行 * 連用形-一般 連用形 一般 * ませ マス ます 助動詞 助動詞 * * * 助動詞-マス 助動詞 マス * 未然形-一般 未然形 一般 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * ませ マス ます 助動詞 助動詞 * * * 助動詞-マス 助動詞 マス * 未然形-一般 未然形 一般 * H080 K1009
無い やっぱり ヤハリ 矢張り 副詞 副詞 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * やっぱり ヤハリ 矢張り 副詞 副詞 * * * * * * * * * * * ない ナイ 無い 形容詞-非自立可能 形容詞 非自立可能 * * 形容詞 形容詞 * * 連体形-一般 連体形 一般 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * ない ナイ 無い 形容詞-非自立可能 形容詞 非自立可能 * * 形容詞 形容詞 * * 連体形-一般 連体形 一般 * の ノ の 助詞-準体助詞 助詞 準体助詞 * * * * * * * * * * でしょう デス です 助動詞 助動詞 * * * 助動詞-デス 助動詞 デス * 意志推量形 意志推量形 * * の ノ の 助詞-準体助詞 助詞 準体助詞 * * * * * * * * * * でしょう デス です 助動詞 助動詞 * * * 助動詞-デス 助動詞 デス * 意志推量形 意志推量形 * * H090 K1130

CTYPE

    my $cForm_gold = <<CFORM;
来る て テ て 助詞-接続助詞 助詞 接続助詞 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * て テ て 助詞-接続助詞 助詞 接続助詞 * * * * * * * * * * き クル 来る 動詞-非自立可能 動詞 非自立可能 * * カ行変格 カ行変格 * * 連用形-一般 連用形 一般 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * き クル 来る 動詞-非自立可能 動詞 非自立可能 * * カ行変格 カ行変格 * * 連用形-一般 連用形 一般 * まし マス ます 助動詞 助動詞 * * * 助動詞-マス 助動詞 マス * 連用形-一般 連用形 一般 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * まし マス ます 助動詞 助動詞 * * * 助動詞-マス 助動詞 マス * 連用形-一般 連用形 一般 * H080 K1050 K2030
ている 持っ モツ 持つ 動詞-一般 動詞 一般 * * 五段-タ行 五段 タ行 * 連用形-促音便 連用形 促音便 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 持っ モツ 持つ 動詞-一般 動詞 一般 * * 五段-タ行 五段 タ行 * 連用形-促音便 連用形 促音便 * て テ て 助詞-接続助詞 助詞 接続助詞 * * * * * * * * * * い イル 居る 動詞-非自立可能 動詞 非自立可能 * * 上一段-ア行 上一段 ア行 * 連用形-一般 連用形 一般 * て テ て 助詞-接続助詞 助詞 接続助詞 * * * * * * * * * * い イル 居る 動詞-非自立可能 動詞 非自立可能 * * 上一段-ア行 上一段 ア行 * 連用形-一般 連用形 一般 * ませ マス ます 助動詞 助動詞 * * * 助動詞-マス 助動詞 マス * 未然形-一般 未然形 一般 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * ませ マス ます 助動詞 助動詞 * * * 助動詞-マス 助動詞 マス * 未然形-一般 未然形 一般 * H100 K1020 K2030
フリー 使える ツカウ 使う 動詞-一般 動詞 一般 * * 下一段-ア行 下一段 ア行 * 連体形-一般 連体形 一般 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 使える ツカウ 使う 動詞-一般 動詞 一般 * * 下一段-ア行 下一段 ア行 * 連体形-一般 連体形 一般 * フリー フリー フリー 名詞-普通名詞-形状詞可能 名詞 普通名詞 形状詞可能 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * フリー フリー フリー 名詞-普通名詞-形状詞可能 名詞 普通名詞 形状詞可能 * * * * * * * * * の ノ の 助詞-格助詞 助詞 格助詞 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * の ノ の 助詞-格助詞 助詞 格助詞 * * * * * * * * * * H000 K1999 K2999
ソフト の ノ の 助詞-格助詞 助詞 格助詞 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * の ノ の 助詞-格助詞 助詞 格助詞 * * * * * * * * * * ソフト ソフト ソフト 名詞-普通名詞-形状詞可能 名詞 普通名詞 形状詞可能 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * ソフト ソフト ソフト 名詞-普通名詞-形状詞可能 名詞 普通名詞 形状詞可能 * * * * * * * * * って ッテ って 助詞-副助詞 助詞 副助詞 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * って ッテ って 助詞-副助詞 助詞 副助詞 * * * * * * * * * * H000 K1999 K2999
有る って ッテ って 助詞-副助詞 助詞 副助詞 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * って ッテ って 助詞-副助詞 助詞 副助詞 * * * * * * * * * * あり アル 有る 動詞-非自立可能 動詞 非自立可能 * * 五段-ラ行 五段 ラ行 * 連用形-一般 連用形 一般 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * あり アル 有る 動詞-非自立可能 動詞 非自立可能 * * 五段-ラ行 五段 ラ行 * 連用形-一般 連用形 一般 * ませ マス ます 助動詞 助動詞 * * * 助動詞-マス 助動詞 マス * 未然形-一般 未然形 一般 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * ませ マス ます 助動詞 助動詞 * * * 助動詞-マス 助動詞 マス * 未然形-一般 未然形 一般 * H080 K1009 K2030
無い やっぱり ヤハリ 矢張り 副詞 副詞 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * やっぱり ヤハリ 矢張り 副詞 副詞 * * * * * * * * * * * ない ナイ 無い 形容詞-非自立可能 形容詞 非自立可能 * * 形容詞 形容詞 * * 連体形-一般 連体形 一般 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * ない ナイ 無い 形容詞-非自立可能 形容詞 非自立可能 * * 形容詞 形容詞 * * 連体形-一般 連体形 一般 * の ノ の 助詞-準体助詞 助詞 準体助詞 * * * * * * * * * * でしょう デス です 助動詞 助動詞 * * * 助動詞-デス 助動詞 デス * 意志推量形 意志推量形 * * の ノ の 助詞-準体助詞 助詞 準体助詞 * * * * * * * * * * でしょう デス です 助動詞 助動詞 * * * 助動詞-デス 助動詞 デス * 意志推量形 意志推量形 * * H090 K1130 K2060

CFORM

    is $bip_data[0], $pos_gold;
    is $bip_data[1], $cType_gold;
    is $bip_data[2], $cForm_gold;
};

# sub train_luwmodel_svm : Tests {};
# sub train_luwmodel_crf : Tests {};
# sub train_bi_model : Tests {};


__PACKAGE__->runtests;
