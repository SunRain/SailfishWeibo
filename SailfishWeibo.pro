# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = SailfishWeibo

CONFIG += sailfishapp

SOURCES += src/SailfishWeibo.cpp \
    src/networkhelper.cpp \
    src/mytype.cpp \
    src/MyNetworkAccessManagerFactory.cpp \
    src/Util.cpp \
    src/Emoticons.cpp

OTHER_FILES += qml/SailfishWeibo.qml \
    qml/cover/CoverPage.qml \
    qml/pages/FirstPage.qml \
    qml/pages/SecondPage.qml \
    rpm/SailfishWeibo.changes.in \
    rpm/SailfishWeibo.spec \
    rpm/SailfishWeibo.yaml \
    translations/*.ts \
    SailfishWeibo.desktop \
    qml/aesyweibo.qml \
    qml/components/Notification.qml \
    qml/components/FooterLoadMore.qml \
    qml/components/DelegateWeibo.qml \
    qml/components/DelegateRepostedWeibo.qml \
    qml/graphics/up.png \
    qml/graphics/toolbarIcon@8.png \
    qml/graphics/Thumbs.db \
    qml/graphics/reload.svg \
    qml/graphics/folder.png \
    qml/graphics/edit.svg \
    qml/js/weiboapi.js \
    qml/js/getURL.js \
    qml/js/dateutils.js \
    qml/js/addImages.js \
    qml/js/WeiboApiHandler.qml \
    qml/ui/WeiboTab.qml \
    qml/ui/WeiboPage.qml \
    qml/ui/WeiboMentioned.qml \
    qml/ui/UserWeibo.qml \
    qml/ui/UserTab.qml \
    qml/ui/UserPhoto.qml \
    qml/ui/UserPage.qml \
    qml/ui/SettingTab.qml \
    qml/ui/SendPage.qml \
    qml/ui/MessageTab.qml \
    qml/ui/LocalPhotoPicker.qml \
    qml/ui/HelloTab.qml \
    qml/ui/Gallery.qml \
    qml/ui/FriendsPage.qml \
    qml/ui/CommentMentioned.qml \
    qml/ui/CommentAllPage.qml \
    qml/ui/AboutPage.qml \
    qml/js/LocalStore.js \
    qml/js/Settings.js \
    qml/components/MainComponent.qml \
    qml/ui/BusyIndicator.qml \
    qml/ui/SendPage.qml.bak \
    qml/components/AtUserComponent.qml \
    qml/graphics/mask_background_grid.png \
    qml/graphics/mask_background_reposted.png \
    qml/graphics/notifactionbar.png \
    qml/graphics/arrow_right.png \
    qml/components/ImagePreviewComponent.qml \
    qml/pages/AboutPage.qml \
    qml/components/LoginComponent.qml \
    translations/SailfishWeibo-zh_CN.ts \
    qml/emoticons/zhh_org.png \
    qml/emoticons/yhh_org.png \
    qml/emoticons/x_org.png \
    qml/emoticons/wq_org.png \
    qml/emoticons/vw_org.png \
    qml/emoticons/unheart.png \
    qml/emoticons/tza_org.png \
    qml/emoticons/tootha_org.png \
    qml/emoticons/t_org.png \
    qml/emoticons/smilea_org.png \
    qml/emoticons/sleepa_org.png \
    qml/emoticons/sk_org.png \
    qml/emoticons/shamea_org.png \
    qml/emoticons/sb_org.png \
    qml/emoticons/sada_org.png \
    qml/emoticons/sad_org.png \
    qml/emoticons/qq_org.png \
    qml/emoticons/otm_org.png \
    qml/emoticons/ok_org.png \
    qml/emoticons/nm_org.png \
    qml/emoticons/money_org.png \
    qml/emoticons/lxh_zhuanfa.png \
    qml/emoticons/lxh_zhenjing.png \
    qml/emoticons/lxh_zana.png \
    qml/emoticons/lxh_youyali.png \
    qml/emoticons/lxh_xuyuan.png \
    qml/emoticons/lxh_xiudada.png \
    qml/emoticons/lxh_xiaohaha.png \
    qml/emoticons/lxh_xiangyixiang.png \
    qml/emoticons/lxh_xianghumobai.png \
    qml/emoticons/lxh_tuijian.png \
    qml/emoticons/lxh_toule.png \
    qml/emoticons/lxh_shuaishuaishou.png \
    qml/emoticons/lxh_quntiweiguan.png \
    qml/emoticons/lxh_qiuguanzhu.png \
    qml/emoticons/lxh_qiubite.png \
    qml/emoticons/lxh_qiaoqiao.png \
    qml/emoticons/lxh_pili.png \
    qml/emoticons/lxh_oye.png \
    qml/emoticons/lxh_meigui.png \
    qml/emoticons/lxh_leiliumanmian.png \
    qml/emoticons/lxh_leifeng.png \
    qml/emoticons/lxh_kunsile.png \
    qml/emoticons/lxh_koubishi.png \
    qml/emoticons/lxh_juhan.png \
    qml/emoticons/lxh_jiujie.png \
    qml/emoticons/lxh_jiekexun.png \
    qml/emoticons/lxh_holdzhu.png \
    qml/emoticons/lxh_haoxihuan.png \
    qml/emoticons/lxh_haojiong.png \
    qml/emoticons/lxh_haobang.png \
    qml/emoticons/lxh_haoaio.png \
    qml/emoticons/lxh_feijin.png \
    qml/emoticons/lxh_deyidexiao.png \
    qml/emoticons/lxh_buxiangshangban.png \
    qml/emoticons/lxh_buhaoyisi.png \
    qml/emoticons/lxh_biefanwo.png \
    qml/emoticons/lxh_bengkui.png \
    qml/emoticons/lxh_beidian.png \
    qml/emoticons/lxh_beicui.png \
    qml/emoticons/lovea_org.png \
    qml/emoticons/licenses.html \
    qml/emoticons/ldln_org.png \
    qml/emoticons/lazu_org.png \
    qml/emoticons/laugh.png \
    qml/emoticons/kl_org.png \
    qml/emoticons/kbsa_org.png \
    qml/emoticons/k_org.png \
    qml/emoticons/j_org.png \
    qml/emoticons/hx.png \
    qml/emoticons/hsa_org.png \
    qml/emoticons/heia_org.png \
    qml/emoticons/hearta_org.png \
    qml/emoticons/hatea_org.png \
    qml/emoticons/han.png \
    qml/emoticons/gza_org.png \
    qml/emoticons/gm.png \
    qml/emoticons/face340.png \
    qml/emoticons/face335.png \
    qml/emoticons/face334.png \
    qml/emoticons/face329.png \
    qml/emoticons/face290.png \
    qml/emoticons/face281.png \
    qml/emoticons/face277.png \
    qml/emoticons/face274.png \
    qml/emoticons/face271.png \
    qml/emoticons/face270.png \
    qml/emoticons/face231.png \
    qml/emoticons/face229.png \
    qml/emoticons/face228.png \
    qml/emoticons/face221.png \
    qml/emoticons/face217.png \
    qml/emoticons/face114.png \
    qml/emoticons/face105.png \
    qml/emoticons/face100.png \
    qml/emoticons/face94.png \
    qml/emoticons/face74.png \
    qml/emoticons/face18.png \
    qml/emoticons/face083.png \
    qml/emoticons/face081.png \
    qml/emoticons/face073.png \
    qml/emoticons/face072.png \
    qml/emoticons/face071.png \
    qml/emoticons/face062.png \
    qml/emoticons/face059.png \
    qml/emoticons/face058.png \
    qml/emoticons/face055.png \
    qml/emoticons/face032.png \
    qml/emoticons/face004.png \
    qml/emoticons/face003.png \
    qml/emoticons/face002.png \
    qml/emoticons/dizzya_org.png \
    qml/emoticons/cza_org.png \
    qml/emoticons/cry.png \
    qml/emoticons/crazya_org.png \
    qml/emoticons/cool_org.png \
    qml/emoticons/cj_org.png \
    qml/emoticons/cake.png \
    qml/emoticons/bz_org.png \
    qml/emoticons/bs_org.png \
    qml/emoticons/bs2_org.png \
    qml/emoticons/bba_org.png \
    qml/emoticons/angrya_org.png \
    qml/emoticons/emoticons.dat
    
# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n
TRANSLATIONS += translations/SailfishWeibo-de.ts \
                translations/SailfishWeibo-zh_CN.ts

HEADERS += \
    src/networkhelper.h \
    src/mytype.h \
    src/app.h \
    src/MyNetworkAccessManagerFactory.h \
    src/Util.h \
    src/Emoticons.h

