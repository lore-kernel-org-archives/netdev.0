From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH 1/2] linux-firmware: update firmware for RTL8111E
Date: Mon, 9 May 2011 16:02:28 +0800
Message-ID: <1304928149-2201-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <romieu@fr.zoreil.com>, <netdev@vger.kernel.org>,
	Hayes Wang <hayeswang@realtek.com>
To: <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:39854 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753224Ab1EIIDn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2011 04:03:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Updated firmware with stability fixes.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 rtl_nic/rtl8168e-1.fw |  Bin 6236 -> 5500 bytes
 rtl_nic/rtl8168e-2.fw |  Bin 3568 -> 3920 bytes
 2 files changed, 0 insertions(+), 0 deletions(-)

diff --git a/rtl_nic/rtl8168e-1.fw b/rtl_nic/rtl8168e-1.fw
index 33104be92d21aecbe9ce5928d909491646d016ce..d203bd5d0dc10580fa7c4b9b0df2792e6ab8f888 100644
GIT binary patch
delta 1684
zcmZvcL1<i66o%h>lR0LQF_~IYO(99ACe~?FqJ#z;4OFY*LR&#$l5P|VQWwQV_j8&=
zkSTOC&_#=3a4DJ5RS>~6wHibcZQ4blh`gCh)7Zj{ZqlYsGJf~H`%Eh?-n;id_uT)S
z^WSstZ-b5W*ZUIE<B58o=MN^*-jkF0@kD?3f{LcG7XK7Y_KEhbi=M0EbzZc8B0rr-
zW&H=DljlUAEsFX_MN>XwnJs%oM^d6WaA8g~?uhP#s`NYfRj_OEU*N-F*3O!B!W3Qv
z$3&ku_#!wBZn3xoPJ!bA&T8o<hAs?Z9kxVkJ4EMmj0C-6#|1miF_y45_#QxN>hnL^
zPCP;48Mq20;ITG9K)1ji=7j;#x7k<mMaztCCA(eu_Ymh0$Nxd}s-4$<6g2^T$c##T
zs8plcAPFk)heUs2Jw_0tRQXp?!xMiCd>d@JA{_B~?43=E_GV|ul4>uV1u(C*{eQ&`
zvcE>P9$6RhZ69O)l4#49RB??t2{?=!_*5Q>Uav5&fNzN2A7{QQdgr?64eUPO$^n!i
z;p~YG(QYQIgQ5o*{W~}#(_%!hL@)@Be{4w>MVAZ-zU7xiUtv612XERv^iGC7<L&U$
zc2&>XQDYN(u+Ikf$0VygCq$p>W}zy2J6eD&sKAg>!T5d1T0^qH4p|-h)*C2*?*>g=
zr)vMyb{}Nu10(-wj;*5yp6Rgni>L8Pi9R<YI`cl~@AZpzA)hSM@t48has(*wM1;Tl
z51tS4AbVnw&(+Z8M0jBvPZ-XhL);#%+Zb*(GT0z)gl&)uNW006XlZc1(V7jG<h=JI
z@7Ui|9}``6>2QZ&eE;&;M3U_7EsD0`Urge&M|4LU=l^JSKT%Qj6Bbcqd4lUjmqxN~
zRXBf+qu4|()G7OX?}#45Hh`4tDfW@X2w#lj622)@`BBk5_$T3hY!As?Zk7FdYzhLh
zS|_8raHbc+Y9Df@r>K6CHScxNFDCOBJG;D*sr+nbw*=H9`CFZH*<d;v>iei%rYU@+
z`PAN9pA4hdt+H425Eb|<G}o|bf=0=>G#SBGdbuh&(HBgEd?4C-Sag(m301!0p&2IO
zVY2r>6kW^F!PSmnqB*44{fFo@*t|B&?^2>8dc;;(yAt}D*Q@v%9eBt-8Z{~>;2Ek7
z9+A7E_YB@GdXTQI?i9TXHV;bu9)ZvBP8e+B)iVTqlYrc}+B2b}c{UA!2{ePfjfcWC
zM4;4>P^lb2oi#{SMVs9D2G_`G5gn><&Woa-Ir-ULqeDv*M!>i_y(VT{zu|b-7)_5g
Yo37(JPKV>T^UWszVD8N4Tc3XKA2%C>vj6}9

delta 2448
zcmZ{meQ1?+6vv<Y+}-0Mr*k^PnRj>dZB94L1YarxF(INCWLBI1B$Q<@68_a6+C7__
zl!H(%2=#}oK!S1aRS^6`Xme>6GILj{=mmRry_=-5YY<Ltx<2Q5o(oF|_V7FB{LcBF
z_ut(_<8LdEH&lqa{GCfRS2Vg!U8%N;CGn9C(MF`1o1(K8i!Qz;+Fd~F6VYcnQ%5T5
zlXq^5dUr+JyG56zq00lh4mykJ*gK-vJx)jT24|jg52trk^ypq-XNg{_7X9%x(H%QP
zr(tvHUHBf+-rj(B;TI%CH)YW|ihK0dLiZk(q`D}rg7L;g%dQ8f+~CZMUfm<Q*PQVU
zuN7U#*_<JtI?>rrixx~iN3@!p^euSKk&sUiNOpl}`e7Vy5EXp1BXc*4zLF5VcOQQf
zNx-RqpFO~CRP;+Oy8+I$i#~)SqtnfzQRD_Nv0e0bStv&*Mq%sC84k>TH?pz`QLAi`
z%HG{6x*v=l?B{Ag4}<$S6|YRrC$b}=3jsKGNOVgF3RI#U<$^`r11K4Nx{&VmLl279
zH3d2jAg0@aZpSekY@w27?@<-*R+)qU!8coHNHp1j<H}Yd#*ueNw01ui&|}j?6VS)@
ziGI*7x(Gct5(KiF!1ke2`<&>|R?&W{QH}1w8qt>NqVb<ak3R<9-&BTRykV+I0@Itp
zD2i6`ZJI&SMf%?YQHP)~DtfI^bU8gN<mr8b=rZWUd!nO`XoJbG;cS`cc}m_yKx1TK
zL5_8TVZowj!FCdyH!qNN<9z;V(Ib^O7tuomV%2h~R_!ACZzb$Xh?ZwLF|?_-K5kq@
z{}__{hw1sfpyzj~&`yHQ(brmK8+HWSVcXDlgUspqC|I^J-iYXBWG7<ifm7O=3|kXj
zBRa`hk(?BL^i{wq<7R-Z9mQ|?-oR;#=*l!Jwp{e1&&m9}=nS%~L~j;lK18|a{etbU
zfo<Gu9|`Rk=Hg7zk6%XT3IY5cw01u;R5Mrf%0cc4Dp|@dUB<316<veF8hW3_d79mx
zMx+jvX~CJ@4RQBFgy;#}MQ%e>+J?+N`byROb*-nrRH2?gyeCBa4g_=MQjIILb|bct
z9@~Eee<4_p!0q9K-vp4o3DJ=MjGi~b+mPCQ7QP-n7V<yA*T752--oY)KQM;V)8RP~
zp69}|&k{=pyXw-nHyOUEkxK;u&>9QMW}>GFn#`L3whi%~=gd>uVWu0oWq!b8NWT_6
zOSV3JM)Vt_2_%X`|6L)u^@{^pEQxTnMT%kedqAV27tH|BX8{@^TOZ7Lz>F^e#;~>5
zJ$;gF6Rf1sr&u#+Kl6d`3^R7ow};7EX1c9|^nV>g(hD<0|FdK<1YPFvYBA~gJZpG~
zDdud0A06jyht6N)yDYkbpl$N+P#JF<!y4xtWsO%*CGLECoLmU)-^SPIOQM4zhIfJf
zKWQLjSA2>$`E`uoheM;8l>cTMWd}H4Ap216v5vlT>{@ZY4V!o^rJo(jN5DevV}%Kf
zgH=8i%a_xCTRZzPuqiI>_tZH!i=jOtwY!2xqyWFGJDBWrz35i9#(p_%MsjRPzlfe<
z;_ZRT4ZyQ8Up>H|4*6^nh1^P%==+(eN{;Bc2lziar+`w*|2T;}-~_(pq==8wn&(Ke
zAMBE^<PeuGd;SlPOth7qq#8~xnD87K^aC_CkPNzRB6xu6G7OvPREd^?%Yyg*cT|LS
zb#fQGNmXwLucqG)Dm|Ge5p2C0`v1Z({pL%*NJ;5g^cEk6<77WhRjiz6yMoNKbr=yq
z$tHtMIW}GW1a&d^WfbfWlf*>WQu_&ZcZzNY!*46uM?BG`1dyvO4>IiQN_|)r7aylD
y^+i=*+$YIp0C<B7{#{_CFdtl<Iyq;<oImNu<YdH&I8LSGL{7&XM^g>eE&l>hAD*ZH

diff --git a/rtl_nic/rtl8168e-2.fw b/rtl_nic/rtl8168e-2.fw
index 7e7d7c220a686dfc31d0dd83b69b55998623e8de..7ea5984cff6b238f2a37907a8396762727f5692a 100644
GIT binary patch
literal 3920
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
SE$?}eJTRxogWk9%&ixM;Tn66&

delta 1897
zcmZ9NPfQ$j6vt<VoyVUd0j0(Qp+JEawAA2gs#T1M8WZiGcrZ{sc!5}rM-vZi_O)f{
zVUs3G(t}aNLt}#MLgK|6HO7-M5n?!+*=0*(o9vosN+DbD^X9j!)x+ey`MrPN_kHg-
z^Go+1oy!x6u8&3g1JS^qq-YAMre78PdiJBl>6Ua!)bm6y{wiARnB7Ud@2}5JhDras
z+0Vj`R9lZ|&t1_>(FOgkqMerDFVWARAPhbGwrE?QXx{^VuVNcEzaNPo5`EnKKEZE5
zbl?HMvvr~g^LtKoqQm)BDx&uiqU9Y)X><;Jk!X}BfiHUSu&BQ(I=w>B3DGmhuwl;w
zv=`Zv6<uu+UGYRuOp6{P`N|p5XI~H<K`$?h?p~uPMGSn{ExL10^julAV0m^$_X?s%
z$rE*?L{CvT&$D=%4v&h~fxeEwt!H>Zzan%*AxoYkdDQlAOqQ4iVq&mQiY||c3h~z{
zR-uq}xwGwxXDFV%BKk%T4X-&c<0-mmrt5B!M`pmOb(}6iZC#H8q8kuq>*L*68b8FD
z>703KSUQMpPBgtq0Z+7jR5VF<Wq^*8caHdMJwTrpy>S+1zH|%+Irhb?QT>vm+K}G|
zxzV=`ZP5-iW<&=U(V^Y+Ueg;yub}s%=O|M8K=d}CN&vWnEFjM#qYcsP7uXBHtnC+F
ze^+#BO0=GswQc6VJ}<hk;0^+)8oMO=GRUT`(;1G((HBg|XB0gu0q(YwatB!u-8e6L
z!HV(ZkFyKN5g5q!iazopdvE9MqWg>7j`w&+-i+Uw|0R&*#+d&;iXep|b{63HDPU@B
z<Y8lkj^jCAWU&Te0>7<4DSV{L3`K*Gx%Y_<ZB>1ldD!oAZv9N*VVB1kj#4Cz>9s)S
zlmv0DKx0*39AP1QL@!e;N>*vdKWcP|Y#bJQ;IbRr|A96DGz|k;mM$0&J;H+4YNVPd
zGK2AMlj!_mhkmH$0P+Tq$HANhfEYI0P0_Cml;;?zFxygs9BDWI0GYrR(OkSE2A2D8
z`w=fNV_U^m^qGHrNWzH2cwzFQ@31g?B=DXW{iYjR7uTj1e3HQLtM3-ad#P%(J6<Fv
ze#chf-L7EVEzLYkGx3hFLuF!qm|*@<k(pEv>|^QEVLY4aXa<blQ1lh(t;_K(U<{Q<
z|9iLXmNd-(c%FO*ME9X*Xr%Kgu3sw)42bxai1W+&<lN*Mr$E$BQlG$pjU42Ca0UHC
z_c56PkjG-03>eY$5@UjqHvtjbNE}N5+8Fcrj%N6Vbkf8eF$<zUk-wJ5{uKpAkpSS#
z2KT>AU}2K2uO4*PgZ3@xX%XE-#^<;2;k?m&Ky7#5bnCXnxplt80=^DI@z3b0YveTw
z*BK+d?2*M9BP{J4-7ho)E@b{+(D5xCEigx5so)aYLK%%qo=cptM0`O0p_ZEvQ%eI@
ze3IhUWe7{n<O}gP$^!#_$k{w><z4rGsNCldnV9|Up|QtiGNJmE+1v9y-}72M&%Y6R
Lo_?Eb>GJ;u^9HdZ

-- 
1.7.3.2

