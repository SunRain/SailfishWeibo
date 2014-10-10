#include "Emoticons.h"

Emoticons *Emoticons::getInstance()
{
    static Emoticons e;
    return &e;
}

Emoticons::~Emoticons()
{
    if (!m_emoticonsHash.isEmpty()) {
        m_emoticonsHash.clear();
    }
}

QString Emoticons::getEmoticonName(const QString &name)
{
    return m_emoticonsHash.value(name, "");
}

Emoticons::Emoticons(QObject *parent)
    :QObject(parent)
{
    initData();
}

void Emoticons::initData()
{
    if (!m_emoticonsHash.isEmpty()) {
        m_emoticonsHash.clear();
    }
    
    m_emoticonsHash.insert("[挖鼻屎]", "kbsa_org.png");
    m_emoticonsHash.insert("[泪]", "sada_org.png");
    m_emoticonsHash.insert("[亲亲]", "qq_org.png");
    m_emoticonsHash.insert("[晕]", "dizzya_org.png");
    m_emoticonsHash.insert("[可爱]", "tza_org.png");
    m_emoticonsHash.insert("[花心]", "hsa_org.png");
    m_emoticonsHash.insert("[汗]", "han.png");
    m_emoticonsHash.insert("[衰]", "cry.png");
    m_emoticonsHash.insert("[偷笑]", "heia_org.png");
    m_emoticonsHash.insert("[打哈欠]", "k_org.png");
    m_emoticonsHash.insert("[睡觉]", "sleepa_org.png");
    m_emoticonsHash.insert("[哼]", "hatea_org.png");
    m_emoticonsHash.insert("[可怜]", "kl_org.png");
    m_emoticonsHash.insert("[右哼哼]", "yhh_org.png");
    m_emoticonsHash.insert("[酷]", "cool_org.png");
    m_emoticonsHash.insert("[生病]", "sb_org.png");
    m_emoticonsHash.insert("[馋嘴]", "cza_org.png");
    m_emoticonsHash.insert("[害羞]", "shamea_org.png");
    m_emoticonsHash.insert("[怒]", "angrya_org.png");
    m_emoticonsHash.insert("[闭嘴]", "bz_org.png");
    m_emoticonsHash.insert("[钱]", "money_org.png");
    m_emoticonsHash.insert("[嘻嘻]", "tootha_org.png");
    m_emoticonsHash.insert("[左哼哼]", "zhh_org.png");
    m_emoticonsHash.insert("[委屈]", "wq_org.png");
    m_emoticonsHash.insert("[鄙视]", "bs2_org.png");
    m_emoticonsHash.insert("[吃惊]", "cj_org.png");
    m_emoticonsHash.insert("[吐]", "t_org.png");
    m_emoticonsHash.insert("[懒得理你]", "ldln_org.png");
    m_emoticonsHash.insert("[思考]", "sk_org.png");
    m_emoticonsHash.insert("[怒骂]", "nm_org.png");
    m_emoticonsHash.insert("[哈哈]", "laugh.png");
    m_emoticonsHash.insert("[抓狂]", "crazya_org.png");
    m_emoticonsHash.insert("[抱抱]", "bba_org.png");
    m_emoticonsHash.insert("[爱你]", "lovea_org.png");
    m_emoticonsHash.insert("[鼓掌]", "gza_org.png");
    m_emoticonsHash.insert("[悲伤]", "bs_org.png");
    m_emoticonsHash.insert("[嘘]", "x_org.png");
    m_emoticonsHash.insert("[呵呵]", "smilea_org.png");
    m_emoticonsHash.insert("[感冒]", "gm.png");
    m_emoticonsHash.insert("[黑线]", "hx.png");
    m_emoticonsHash.insert("[愤怒]", "face335.png");
    m_emoticonsHash.insert("[失望]", "face032.png");
    m_emoticonsHash.insert("[做鬼脸]", "face290.png");
    m_emoticonsHash.insert("[阴险]", "face105.png");
    m_emoticonsHash.insert("[困]", "face059.png");
    m_emoticonsHash.insert("[拜拜]", "face062.png");
    m_emoticonsHash.insert("[疑问]", "face055.png");
    m_emoticonsHash.insert("[赞]", "face329.png");
    m_emoticonsHash.insert("[心]", "hearta_org.png");
    m_emoticonsHash.insert("[伤心]", "unheart.png");
    m_emoticonsHash.insert("[囧]", "j_org.png");
    m_emoticonsHash.insert("[奥特曼]", "otm_org.png");
    m_emoticonsHash.insert("[蜡烛]", "lazu_org.png");
    m_emoticonsHash.insert("[蛋糕]", "cake.png");
    m_emoticonsHash.insert("[弱]", "sad_org.png");
    m_emoticonsHash.insert("[ok]", "ok_org.png");
    m_emoticonsHash.insert("[威武]", "vw_org.png");
    m_emoticonsHash.insert("[猪头]", "face281.png");
    m_emoticonsHash.insert("[月亮]", "face18.png");
    m_emoticonsHash.insert("[浮云]", "face229.png");
    m_emoticonsHash.insert("[咖啡]", "face74.png");
    m_emoticonsHash.insert("[爱心传递]", "face221.png");
    m_emoticonsHash.insert("[来]", "face277.png");
    m_emoticonsHash.insert("[熊猫]", "face002.png");
    m_emoticonsHash.insert("[帅]", "face94.png");
    m_emoticonsHash.insert("[不要]", "face274.png");
    m_emoticonsHash.insert("[笑哈哈]", "lxh_xiaohaha.png");
    m_emoticonsHash.insert("[好爱哦]", "lxh_haoaio.png");
    m_emoticonsHash.insert("[噢耶]", "lxh_oye.png");
    m_emoticonsHash.insert("[偷乐]", "lxh_toule.png");
    m_emoticonsHash.insert("[泪流满面]", "lxh_leiliumanmian.png");
    m_emoticonsHash.insert("[巨汗]", "lxh_juhan.png");
    m_emoticonsHash.insert("[抠鼻屎]", "lxh_koubishi.png");
    m_emoticonsHash.insert("[求关注]", "lxh_qiuguanzhu.png");
    m_emoticonsHash.insert("[好喜欢]", "lxh_haoxihuan.png");
    m_emoticonsHash.insert("[崩溃]", "lxh_bengkui.png");
    m_emoticonsHash.insert("[好囧]", "lxh_haojiong.png");
    m_emoticonsHash.insert("[震惊]", "lxh_zhenjing.png");
    m_emoticonsHash.insert("[别烦我]", "lxh_biefanwo.png");
    m_emoticonsHash.insert("[不好意思]", "lxh_buhaoyisi.png");
    m_emoticonsHash.insert("[羞嗒嗒]", "lxh_xiudada.png");
    m_emoticonsHash.insert("[得意地笑]", "lxh_deyidexiao.png");
    m_emoticonsHash.insert("[纠结]", "lxh_jiujie.png");
    m_emoticonsHash.insert("[给劲]", "lxh_feijin.png");
    m_emoticonsHash.insert("[悲催]", "lxh_beicui.png");
    m_emoticonsHash.insert("[甩甩手]", "lxh_shuaishuaishou.png");
    m_emoticonsHash.insert("[好棒]", "lxh_haobang.png");
    m_emoticonsHash.insert("[瞧瞧]", "lxh_qiaoqiao.png");
    m_emoticonsHash.insert("[不想上班]", "lxh_buxiangshangban.png");
    m_emoticonsHash.insert("[困死了]", "lxh_kunsile.png");
    m_emoticonsHash.insert("[许愿]", "lxh_xuyuan.png");
    m_emoticonsHash.insert("[丘比特]", "lxh_qiubite.png");
    m_emoticonsHash.insert("[有鸭梨]", "lxh_youyali.png");
    m_emoticonsHash.insert("[想一想]", "lxh_xiangyixiang.png");
    m_emoticonsHash.insert("[躁狂症]", "lxh_kuangzaozheng.png");
    m_emoticonsHash.insert("[转发]", "lxh_zhuanfa.png");
    m_emoticonsHash.insert("[互相膜拜]", "lxh_xianghumobai.png");
    m_emoticonsHash.insert("[雷锋]", "lxh_leifeng.png");
    m_emoticonsHash.insert("[杰克逊]", "lxh_jiekexun.png");
    m_emoticonsHash.insert("[玫瑰]", "lxh_meigui.png");
    m_emoticonsHash.insert("[hold住]", "lxh_holdzhu.png");
    m_emoticonsHash.insert("[群体围观]", "lxh_quntiweiguan.png");
    m_emoticonsHash.insert("[推荐]", "lxh_tuijian.png");
    m_emoticonsHash.insert("[赞啊]", "lxh_zana.png");
    m_emoticonsHash.insert("[被电]", "lxh_beidian.png");
    m_emoticonsHash.insert("[霹雳]", "lxh_pili.png");
}

