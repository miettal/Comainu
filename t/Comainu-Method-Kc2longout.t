package t::Comainu::Method::Kc2longout;
use strict;
use warnings;
use utf8;

use lib 'lib', 't/lib';
use Test::Comainu;

use parent 'Test::Class';
use Test::More;
use Test::Mock::Guard;

sub _use_ok : Test(startup => 1) {
    use_ok 'Comainu::Method::Kc2longout';
}

sub create_features : Test(6) {
    my $kc2_data = "";
    my $g = guard_write_to_file('Comainu::Method::Kc2longout', \$kc2_data);

    subtest "sentence boundary (CRF)" => sub {
        my $kc2longout = Comainu::Method::Kc2longout->new(
            boundary => "sentence",
            'crf-dir' => 'local/bin',
            'yamcha-dir' => 'local/bin',
        );
        $kc2longout->create_features("t/sample/kc2longout/test.KC", "t/sample/kc2longout/test.Kc2");
        is $kc2_data, read_from_file('t/sample/kc2longout/test.KC2.crf_boundary');
    };

    subtest "word boundary (CRF)" => sub {
        my $kc2longout = Comainu::Method::Kc2longout->new(
            boundary => "word",
            'crf-dir' => 'local/bin',
            'yamcha-dir' => 'local/bin',
        );
        $kc2longout->create_features("t/sample/kc2longout/test.KC", "t/sample/kc2longout/test.KC2");
        is $kc2_data, read_from_file('t/sample/kc2longout/test.KC2.crf_word');
    };

    subtest "none boundary (CRF)" => sub {
        my $kc2longout = Comainu::Method::Kc2longout->new(
            boundary => "none",
            'crf-dir' => 'local/bin',
            'yamcha-dir' => 'local/bin',
        );
        $kc2longout->create_features("t/sample/kc2longout/test.KC", "t/sample/kc2longout/test.KC2");
        is $kc2_data, read_from_file('t/sample/kc2longout/test.KC2.crf_none');
    };

    subtest "sentence boundary (SVM)" => sub {
        my $kc2longout = Comainu::Method::Kc2longout->new(
            "boundary"      => "sentence",
            "luwmodel-type" => 'SVM',
            'yamcha-dir'    => 'local/bin',
        );
        $kc2longout->create_features("t/sample/kc2longout/test.KC", "t/sample/kc2longout/test.Kc2");
        is $kc2_data, read_from_file('t/sample/kc2longout/test.KC2.svm_boundary');
    };

    subtest "word boundary (SVM)" => sub {
        my $kc2longout = Comainu::Method::Kc2longout->new(
            "boundary"      => "word",
            "luwmodel-type" => 'SVM',
            'yamcha-dir'    => 'local/bin',
        );
        $kc2longout->create_features("t/sample/kc2longout/test.KC", "t/sample/kc2longout/test.KC2");
        is $kc2_data, read_from_file('t/sample/kc2longout/test.KC2.svm_word');
    };

    subtest "none boundary (SVM)" => sub {
        my $kc2longout = Comainu::Method::Kc2longout->new(
            "boundary"      => "none",
            "luwmodel-type" => 'SVM',
            'yamcha-dir'    => 'local/bin',
        );
        $kc2longout->create_features("t/sample/kc2longout/test.KC", "t/sample/kc2longout/test.KC2");
        is $kc2_data, read_from_file('t/sample/kc2longout/test.KC2.svm_none');
    };
}

sub chunk_luw : Test(1) {
    my $kc2longout = Comainu::Method::Kc2longout->new(
        boundary => "sentence",
        "comainu-temp" => "t/sample/kc2longout",
        'crf-dir' => 'local/bin',
        'yamcha-dir' => 'local/bin',
    );

    my $svmout_data = "";
    my $g1 = guard_write_to_file('Comainu::Method::Kc2longout', \$svmout_data);
    my $g2 = mock_guard('Comainu::Method::Kc2longout', {
        proc_file2stdout => sub { read_from_file('t/sample/kc2longout/test.KC.svmout.system') },
    });

    $kc2longout->chunk_luw('t/sample/kc2longout/test.KC', 't/sample/kc2longout/test.KC.svmout');

    is $svmout_data, read_from_file('t/sample/kc2longout/test.KC.svmout.gold');
};

sub merge_chunk_result : Test(1) {
    my $kc2longout = Comainu::Method::Kc2longout->new(
        boundary => 'sentence',
        debug    => 1,
    );

    my $lout_data = "";
    my $g1 = guard_write_to_file('Comainu::Method::Kc2longout', \$lout_data);

    $kc2longout->merge_chunk_result('t/sample/kc2longout/test.KC', 't/sample/kc2longout/test.KC.svmout.gold', 't/sample/kc2ongout/test.KC.lout');

    is $lout_data, read_from_file('t/sample/kc2longout/test.KC.lout.gold');
};

# sub post_process : Tests {};

sub create_long_lemma : Test(4) {
    my $kc2longout = Comainu::Method::Kc2longout->new;
    my $comp_file = "t/sample/Comp.txt";

    subtest "create_long_lemma" => sub {
        my $data = <<DATA;
Ba ミスター ミスター ミスター 名詞-普通名詞-一般 * * ミスター ミスター ミスター ミスター * * 外 名詞-普通名詞-一般 * * ミスター ミスター ミスター
Ba の ノ の 助詞-格助詞 * * ノ ノ の の * * 和 助詞-格助詞 * * ノ の の
Ba 「 * 「 補助記号-括弧開 * *   「 「 * * 記号 補助記号-括弧開 * * 「 「 「
B 甘い アマイ 甘い 形容詞-一般 形容詞 連体形-一般 アマイ アマイ 甘い 甘い * * 和 名詞-普通名詞-一般 * * アマイモノギライ 甘い物嫌い 甘いもの嫌い
I もの モノ 物 名詞-普通名詞-サ変可能 * * モノ モノ 物 物 * * 和 * * * * * *
I 嫌い キライ 嫌い 名詞-普通名詞-形状詞可能 * * ギライ キライ 嫌い 嫌い * * 和 * * * * * *
Ba 」 * 」 補助記号-括弧閉 * *   」 」 * * 記号 補助記号-括弧閉 * * 」 」 」
Ba は ハ は 助詞-係助詞 * * ハ ハ は は * * 和 助詞-係助詞 * * ハ は は
Ba キャラ作り キャラヅクリ キャラ作り 名詞-普通名詞-一般 * * キャラヅクリ キャラヅクリ キャラ作り キャラ作り * * 混 名詞-普通名詞-一般 * * キャラヅクリ キャラ作り キャラ作り
Ba だ ダ だ 助動詞 助動詞-ダ 終止形-一般 ダ ダ だ だ * * 和 助動詞 助動詞-ダ 終止形-一般 ダ だ だ
B と ト と 助詞-格助詞 * * ト ト と と * * 和 助詞-格助詞 * * トイウ という という
I いう イウ 言う 動詞-一般 五段-ワア行-イウ 連体形-一般 イウ イウ 言う 言う * * 和 * * * * * *
B 噂 ウワサ 噂 名詞-普通名詞-サ変可能 * * ウワサ ウワサ 噂 噂 * * 和 名詞-普通名詞-一般 * * ウワサ 噂 噂
Ba も モ も 助詞-係助詞 * * モ モ も も * * 和 助詞-係助詞 * * モ も も
Ba 。 * 。 補助記号-句点 * *   。 。 * * 記号 補助記号-句点 * *  。 。
EOS
DATA

        my $gold = <<GOLD;
Ba ミスター ミスター ミスター 名詞-普通名詞-一般 * * ミスター ミスター ミスター ミスター * * 外 名詞-普通名詞-一般 * * ミスター ミスター ミスター
Ba の ノ の 助詞-格助詞 * * ノ ノ の の * * 和 助詞-格助詞 * * ノ の の
Ba 「 * 「 補助記号-括弧開 * *   「 「 * * 記号 補助記号-括弧開 * *  「 「
B 甘い アマイ 甘い 形容詞-一般 形容詞 連体形-一般 アマイ アマイ 甘い 甘い * * 和 名詞-普通名詞-一般 * * アマイモノギライ 甘い物嫌い 甘いもの嫌い
I もの モノ 物 名詞-普通名詞-サ変可能 * * モノ モノ 物 物 * * 和 * * * * * *
I 嫌い キライ 嫌い 名詞-普通名詞-形状詞可能 * * ギライ キライ 嫌い 嫌い * * 和 * * * * * *
Ba 」 * 」 補助記号-括弧閉 * *   」 」 * * 記号 補助記号-括弧閉 * *  」 」
Ba は ハ は 助詞-係助詞 * * ハ ハ は は * * 和 助詞-係助詞 * * ハ は は
Ba キャラ作り キャラヅクリ キャラ作り 名詞-普通名詞-一般 * * キャラヅクリ キャラヅクリ キャラ作り キャラ作り * * 混 名詞-普通名詞-一般 * * キャラヅクリ キャラ作り キャラ作り
Ba だ ダ だ 助動詞 助動詞-ダ 終止形-一般 ダ ダ だ だ * * 和 助動詞 助動詞-ダ 終止形-一般 ダ だ だ
B と ト と 助詞-格助詞 * * ト ト と と * * 和 助詞-格助詞 * * トイウ という という
I いう イウ 言う 動詞-一般 五段-ワア行-イウ 連体形-一般 イウ イウ 言う 言う * * 和 * * * * * *
B 噂 ウワサ 噂 名詞-普通名詞-サ変可能 * * ウワサ ウワサ 噂 噂 * * 和 名詞-普通名詞-一般 * * ウワサ 噂 噂
Ba も モ も 助詞-係助詞 * * モ モ も も * * 和 助詞-係助詞 * * モ も も
Ba 。 * 。 補助記号-句点 * *   。 。 * * 記号 補助記号-句点 * *  。 。
EOS
GOLD

        is $kc2longout->create_long_lemma($data, $comp_file), $gold;
    };

    subtest "parential" => sub {
        my $data = <<DATA;
Ba テレビ テレビ テレビ 名詞-普通名詞-一般 * * テレビ テレビ テレビ テレビ * * 外 名詞-普通名詞-一般 * * テレビ テレビ テレビ
Ba で デ で 助詞-格助詞 * * デ デ で で * * 和 助詞-格助詞 * * デ で で
Ba は ハ は 助詞-係助詞 * * ハ ハ は は * * 和 助詞-係助詞 * * ハ は は
Ba 人気 ニンキ 人気 名詞-普通名詞-一般 * * ニンキ ニンキ 人気 人気 * * 漢 名詞-普通名詞-一般 * * ニンキコメディ「フレンズ」 人気コメディ「フレンズ」 人気コメディ「フレンズ」
I コメディ コメディー コメディー 名詞-普通名詞-一般 * * コメディ コメディ コメディ コメディ * * 外 * * * * * *
I 「 * 「 補助記号-括弧開 * * * * 「 「 * * 記号 * * * * * *
I フレンズ フレンド フレンド 名詞-普通名詞-一般 * * フレンズ フレンズ フレンズ フレンズ * * 外 * * * * * *
I 」 * 」 補助記号-括弧閉 * * * * 」 」 * * 記号 * * * * * *
Ba （ * （ 補助記号-括弧開 * * * * （ （ * * 記号 補助記号-括弧開 * * * （ （
Ba 二千 ニセン 二千 名詞-数詞 * * ニセン ニセン 二千 二千 * * 漢 名詞-数詞 * * ニセンネン 二千年 二千年
I 年 ネン 年 名詞-普通名詞-助数詞可能 * * ネン ネン 年 年 * * 漢 * * * * * *
Ba ） * ） 補助記号-括弧閉 * * * * ） ） * * 記号 補助記号-括弧閉 * * * ） ）
Ba に ニ に 助詞-格助詞 * * ニ ニ に に * * 和 助詞-格助詞 * * ニ に に
B ゲスト ゲスト ゲスト 名詞-普通名詞-一般 * * ゲスト ゲスト ゲスト ゲスト * * 外 動詞-一般 サ行変格 連用形-一般 ゲストシュツエンスル ゲスト出演する ゲスト出演し
I 出演 シュツエン 出演 名詞-普通名詞-サ変可能 * * シュツエン シュツエン 出演 出演 * * 漢 * * * * * *
I し スル 為る 動詞-非自立可能 サ行変格 連用形-一般 シ スル する する * * 和 * * * * * *
DATA

        my $gold = <<GOLD;
Ba テレビ テレビ テレビ 名詞-普通名詞-一般 * * テレビ テレビ テレビ テレビ * * 外 名詞-普通名詞-一般 * * テレビ テレビ テレビ
Ba で デ で 助詞-格助詞 * * デ デ で で * * 和 助詞-格助詞 * * デ で で
Ba は ハ は 助詞-係助詞 * * ハ ハ は は * * 和 助詞-係助詞 * * ハ は は
Ba 人気 ニンキ 人気 名詞-普通名詞-一般 * * ニンキ ニンキ 人気 人気 * * 漢 名詞-普通名詞-一般 * * ニンキコメディフレンズ 人気コメディフレンズ 人気コメディ「フレンズ」
I コメディ コメディー コメディー 名詞-普通名詞-一般 * * コメディ コメディ コメディ コメディ * * 外 * * * * * *
I 「 * 「 補助記号-括弧開 * *   「 「 * * 記号 * * * * * *
I フレンズ フレンド フレンド 名詞-普通名詞-一般 * * フレンズ フレンズ フレンズ フレンズ * * 外 * * * * * *
I 」 * 」 補助記号-括弧閉 * *   」 」 * * 記号 * * * * * *
Ba （ * （ 補助記号-括弧開 * *   （ （ * * 記号 補助記号-括弧開 * *  （ （
Ba 二千 ニセン 二千 名詞-数詞 * * ニセン ニセン 二千 二千 * * 漢 名詞-数詞 * * ニセンネン 二千年 二千年
I 年 ネン 年 名詞-普通名詞-助数詞可能 * * ネン ネン 年 年 * * 漢 * * * * * *
Ba ） * ） 補助記号-括弧閉 * *   ） ） * * 記号 補助記号-括弧閉 * *  ） ）
Ba に ニ に 助詞-格助詞 * * ニ ニ に に * * 和 助詞-格助詞 * * ニ に に
B ゲスト ゲスト ゲスト 名詞-普通名詞-一般 * * ゲスト ゲスト ゲスト ゲスト * * 外 動詞-一般 サ行変格 連用形-一般 ゲストシュツエンスル ゲスト出演する ゲスト出演し
I 出演 シュツエン 出演 名詞-普通名詞-サ変可能 * * シュツエン シュツエン 出演 出演 * * 漢 * * * * * *
I し スル 為る 動詞-非自立可能 サ行変格 連用形-一般 シ スル する する * * 和 * * * * * *
GOLD

        is $kc2longout->create_long_lemma($data, $comp_file), $gold;
    };

    subtest "parential 2" => sub {
        my $data = <<DATA;
Ba 経済 ケイザイ 経済 名詞-普通名詞-一般 * * ケイザイ ケイザイ 経済 経済 * * 漢 名詞-普通名詞-一般 * * ケイザイカツドウ 経済活動 経済活動
I 活動 カツドウ 活動 名詞-普通名詞-サ変可能 * * カツドウ カツドウ 活動 活動 * * 漢 * * * * * *
Ba を ヲ を 助詞-格助詞 * * ヲ ヲ を を * * 和 助詞-格助詞 * * ヲ を を
B 萎縮 イシュク 萎縮 名詞-普通名詞-サ変可能 * * イシュク イシュク 萎縮 萎縮 * * 漢 動詞-一般 サ行変格 未然形-サ イシュク（イシュク）スル 萎縮（いしゅく）する 萎縮(いしゅく)さ
I （ * （ 補助記号-括弧開 * *   （ （ * * * * * * * * *
I いしゅく イシュク 萎縮 名詞-普通名詞-サ変可能 * * イシュク イシュク 萎縮 萎縮 * * 漢 * * * * * *
I ） * ） 補助記号-括弧閉 * *   ） ） * * * * * * * * *
I さ スル 為る 動詞-非自立可能 サ行変格 未然形-サ サ スル する する * * 和 * * * * * *
Ba せる セル せる 助動詞 下一段-サ行 連体形-一般 セル セル せる せる * * 和 助動詞 下一段-サ行 連体形-一般 セル せる せる
DATA

        my $gold = <<GOLD;
Ba 経済 ケイザイ 経済 名詞-普通名詞-一般 * * ケイザイ ケイザイ 経済 経済 * * 漢 名詞-普通名詞-一般 * * ケイザイカツドウ 経済活動 経済活動
I 活動 カツドウ 活動 名詞-普通名詞-サ変可能 * * カツドウ カツドウ 活動 活動 * * 漢 * * * * * *
Ba を ヲ を 助詞-格助詞 * * ヲ ヲ を を * * 和 助詞-格助詞 * * ヲ を を
B 萎縮 イシュク 萎縮 名詞-普通名詞-サ変可能 * * イシュク イシュク 萎縮 萎縮 * * 漢 動詞-一般 サ行変格 未然形-サ イシュクスル 萎縮する 萎縮(いしゅく)さ
I （ * （ 補助記号-括弧開 * *   （ （ * * * * * * * * *
I いしゅく イシュク 萎縮 名詞-普通名詞-サ変可能 * * イシュク イシュク 萎縮 萎縮 * * 漢 * * * * * *
I ） * ） 補助記号-括弧閉 * *   ） ） * * * * * * * * *
I さ スル 為る 動詞-非自立可能 サ行変格 未然形-サ サ スル する する * * 和 * * * * * *
Ba せる セル せる 助動詞 下一段-サ行 連体形-一般 セル セル せる せる * * 和 助動詞 下一段-サ行 連体形-一般 セル せる せる
GOLD

        is $kc2longout->create_long_lemma($data, $comp_file), $gold;
    };

    subtest "compose" => sub {
        my $data = <<DATA;
B 遠く トオク 遠く 名詞-普通名詞-副詞可能 * * トオク トオク 遠く 遠く * * 和 名詞-普通名詞-一般 * * トオク 遠く 遠く
Ba の ノ の 助詞-格助詞 * * ノ ノ の の * * 和 助詞-格助詞 * * ノ の の
B お オ 御 接頭辞 * * オ オ 御 御 * * 和 名詞-普通名詞-一般 * * オミセ 御店 お店
Ia 店 ミセ 店 名詞-普通名詞-一般 * * ミセ ミセ 店 店 * * 和 * * * * * *
Ba に ニ に 助詞-格助詞 * * ニ ニ に に * * 和 助詞-格助詞 * * ニ に に
B 行っ イク 行く 動詞-非自立可能 五段-カ行-イク 連用形-促音便 イッ イク 行く 行っ * * 和 動詞-一般 五段-カ行-イク 連用形-促音便 イク 行く 行っ
B て テ て 助詞-接続助詞 * * テ テ て て * * 和 助動詞 五段-ワア行-一般 連用形-促音便 テシマウ て仕舞う てしまっ
I しまっ シマウ 仕舞う 動詞-非自立可能 五段-ワア行-一般 連用形-促音便 シマッ シマウ 仕舞う 仕舞っ * * 和 * * * * * *
Ba て テ て 助詞-接続助詞 * * テ テ て て * * 和 助詞-接続助詞 * * テ て て
Ba は ハ は 助詞-係助詞 * * ハ ハ は は * * 和 助詞-係助詞 * * ハ は は
DATA

        my $gold = <<GOLD;
B 遠く トオク 遠く 名詞-普通名詞-副詞可能 * * トオク トオク 遠く 遠く * * 和 名詞-普通名詞-一般 * * トオク 遠く 遠く
Ba の ノ の 助詞-格助詞 * * ノ ノ の の * * 和 助詞-格助詞 * * ノ の の
B お オ 御 接頭辞 * * オ オ 御 御 * * 和 名詞-普通名詞-一般 * * オミセ 御店 お店
Ia 店 ミセ 店 名詞-普通名詞-一般 * * ミセ ミセ 店 店 * * 和 * * * * * *
Ba に ニ に 助詞-格助詞 * * ニ ニ に に * * 和 助詞-格助詞 * * ニ に に
B 行っ イク 行く 動詞-非自立可能 五段-カ行-イク 連用形-促音便 イッ イク 行く 行っ * * 和 動詞-一般 五段-カ行-イク 連用形-促音便 イク 行く 行っ
B て テ て 助詞-接続助詞 * * テ テ て て * * 和 助動詞 五段-ワア行-一般 連用形-促音便 テシマウ てしまう てしまっ
I しまっ シマウ 仕舞う 動詞-非自立可能 五段-ワア行-一般 連用形-促音便 シマッ シマウ 仕舞う 仕舞っ * * 和 * * * * * *
Ba て テ て 助詞-接続助詞 * * テ テ て て * * 和 助詞-接続助詞 * * テ て て
Ba は ハ は 助詞-係助詞 * * ハ ハ は は * * 和 助詞-係助詞 * * ハ は は
GOLD

        is $kc2longout->create_long_lemma($data, $comp_file), $gold;
    };
};

sub generate_long_lemma : Test(1) {
    my $kc2longout = Comainu::Method::Kc2longout->new;

    my $create_luw = sub {
        my $data = shift;
        my @lines = split /\n/, $data;
        return [ map {
            my @items = split / /, $_;
            do { $items[$_] = "" if $items[$_] eq "*"; } for (7..10);
            \@items;
        } @lines ];
    };

    subtest '括弧' => sub {
        my $data = "Ba 「 * 「 補助記号-括弧開 * * * * 「 「 * * 記号 補助記号-括弧開 * *   「";
        my $luw = $create_luw->($data);

        $kc2longout->generate_long_lemma($luw, 0);
        is $luw->[0]->[17], "";
        is $luw->[0]->[18], "「";
    };
};


__PACKAGE__->runtests;
