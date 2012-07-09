From: Hayes Wang <hayeswang@realtek.com>
Subject: =?	?q?=5BPATCH=20firmware=204/4=5D=20rtl=5Fnic=3A=20add=20new=20firmware=20for=20RTL8168G?=
Date: Mon, 9 Jul 2012 11:11:52 +0800
Message-ID: <1341803512-1309-4-git-send-email-hayeswang@realtek.com>
References: <1341803512-1309-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="\"\""
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <romieu@fr.zoreil.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <dwmw2@infradead.org>, <ben@decadent.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1341803512-1309-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46ile: rtl_nic/rtl8168g-1.fw
Version: 0.0.1

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 WHENCE                |    3 +++
 rtl_nic/rtl8168g-1.fw |  Bin 0 -> 4272 bytes
 2 files changed, 3 insertions(+)
 create mode 100644 rtl_nic/rtl8168g-1.fw

diff --git a/WHENCE b/WHENCE
index 8f2b610..1fb7951 100644
--- a/WHENCE
+++ b/WHENCE
@@ -1816,6 +1816,9 @@ Version: 0.0.1
 File: rtl_nic/rtl8106e-1.fw
 Version: 0.0.1
=20
+File: rtl_nic/rtl8168g-1.fw
+Version: 0.0.1
+
 Licence:
  * Copyright =C2=A9 2011, Realtek Semiconductor Corporation
  *
diff --git a/rtl_nic/rtl8168g-1.fw b/rtl_nic/rtl8168g-1.fw
new file mode 100644
index 0000000000000000000000000000000000000000..dace1ea98c66de08107ee08=
57d8a8680d57d7898
GIT binary patch
literal 4272
zcma)=3D4Q!QH8OP6kds{wM$}K%Y`H<dLC`AQsTT|vXp)D<277}sMEg(r-8Eiyx70{Tt
zg@+5Q`*4D8GRDSMM{zKrWJV2H7`HfNer#-IQFJ8p!hjiry~bsQF`)jQd(PWlnweNQ
zdCqyx^YK6b^PF?u))-^ftozoD)pa-CGpo8KF*`B4I-aPTQ}e|+)iuoNPb;lBYRsMH
zjzx7fHMI>bYuZ+~EWhvW6)o*;>z3c!QeBg%P1LolUbS|4yt?kDnlJF*JodEuCT}Pc
zV`BWv{_m0O*tAECNvo>fn0UPjI`1}St1<bB1*6Mk;f4}1pRp1@SR%2&it4n#mHxO+
z=3D8P4KjDFtAWZDW^!7M9NPg?m&y_M+8RyHN9^iQ$!ChZ;CK)03P0BsBXA6bbUx6+=3Dr
zV#d-(A3;A3|9`X$*+sBBi|>DCSXug(l^wlSMq#t1)yg*+Kf-uAxewES$oEGwzeX_}
zu`-vr@6nI>{&(mHzTZwi;`?8p;NotrwNkUp%B}dRPGddZ=3DH_;S>rs4kjg77N{%Xi(
zE#pJXFU0R(l~&}JRvPxe-xK8SaQ+t>t*pjw#0e{lvCBgakniR@t$eq}%3b$csmCuM
z?#;y5hOLeZ{P<+Gl~!+4<aIG*@Q|}BdcyfB_sV&&*Ge&1o9n?tKac%*X$iKw!Txh_
zF}HxZn78XBU+o`he*!zYAAoUy@c`p;#)03jSk8W}oPeG^>Og9|XNaNvbgj4Y2L5Nj
z5%qrYVSZ8kny^>9IG92_FEbvS24g<8fPdtmi`iOl<*1L_hhA+0ZxeW%wokB$VxzI2
zYP}xYdiLJ@*2?^&aPvBOUck=3DdC?!tpDcWW@uX4HmSDcY>`N01ft8ymi1FlX{&!&gw
z{miTM!C`(!J7(p`YslZzz-2~~-|s_2_u*l5f1sf=3D?2XPxS-(o<UOA0!cjHf5x7vm4
z+&+vGU9Zk--DtgB*8SsLYn;Q_wx-#uQLes{?33nOj@@k&Ig3?J|H@1-?!kW-+-{<N
zHgJxT@cTTi$HnTz=3DTl>>s4V=3DFi?fKm{mp0bBS#Q8yRGEZ9Q*uSAu$xokB8}th@U23
zSVudD&Bs|+-aS@kv6gv18^U4gIkVX6-8H`pJ#+CMm!q8XHV=3D$FU@RDhF?)u*U4$56
zz3%=3DrHOije3r<~sob`uws&j$&(Y(q@jQMhM=3DIY}cIIpy=3D*b8$v(dw~HfG_6#PlM^=
u
zXvfVDJvYL9!sk_<3*l*6gIi0y&FyIwYr2oMtYW<p_GkrC`BXfmX)py=3DE|E{b74^A>
zbCl0~6?k&z4{czr<W|ga<_=3D*~@BKrpDu?r^b)q<%8o>i!8dGaeaXt%9#U?FIHws-R
zx-O6Xaisd^;>fM-9j({bPFUNM{QFga{0kgLksppA7V`B1xImt|$U1V~zRry$vXM9H
zz&<MnH(J+!!^+$AqXE7<tnB4nY@&bQYgVox<NML)@y0#K9{c_))M171_e{1jftbO2
zRxV;wN<Z=3Dq>KF{S!RIZEFRkJXe#Cxd;Gqw@n3H8C<n86&P2vAfD@z*blQZ>wE3bBd
z5#HXaV6M>09n7h3CwNspdfdqm@z?QQ-XWEv-*z(gZzs2WU}XdPsSzh{zro4-iK+Va
z<KT)I`hC#%Yu;Z$QiBhxY~ro<<EQ=3Dj8I><s*^NAb42+ePMOHTBpWz+5whi8{qK{hn
zHua}m2H5?Ae1+OSiXHti+8@a~HOA?q)WqdWj-%vh?ut29CUFNP)AXldTMp;l4rl*e
zd`~c*mV|4tHz|LtU-^q+GmhB(i>#c(e-1Vpqn{X|&o=3Dhq$~E>S%AC(t%AGZstHMep
zakAJi5SRTP%=3D2fLrzo6%*UC=3DjHBLX6&k^UkoWxR`(JQ>8)Ic%3RZ}}B^1<x6i^A7O
ztUYs?x}jFoMr$p#jQe^4-zfncJjpj&6>q(+^@x=3Dx8#!P5uwnmR%dv@KW2k`<;446G
zK0tlnPF!kO<5p_i>8zpI#XUpZwVIE8nA?vHat^Ybx(;4+e99U2YaQ!@^T~6qyof9z
zUO<lEb5@GL7ktIl!C3m4T|;%C91qrh+RA?L*3R(jIGnSNQM{La9s9vl&N`ZPtxKFu
z$9r%#Kz;)kU@s;{2b`za$5S0{En~1v6<c}Nk28$JdQ=3D?BZ!i3&h!Ogvuo-Tzd)3j$
zn?gR75nn6e{xl@@egPYM`1j4MA08rpymS)0D=3D#{Rqw|b&>n-FWTa(nM*5pj$Nt$(W
zF9a2Q>*BBT7g?ju&tN{g?<J0la_Tob9`DA*oTu`sUN_O{#(7=3Dxyp`wSb+qv{N=3D!W$
z8nZFX)8z6rp<5Wh5BlkTFEZ>!3Jg>HxRCKw_E2?YxjL|^t}0h&o$e*#YYk_8!F(RO
zMsg+l;H|;&a}|!2_rW`W^>;3`k`L|&@$G(uF?VWS#L7g*8P=3D(LJKU#VIgJnFlzd+e
z*Q%T{pIyJ!7yJyKr3&iY<3GnbZv~^Cv0m&`d7LRf*GJ7PWbQQBG)@)gC3y~v#O@_m
zidqY8yRq%%o=3DZ_Hp)QS1xsG4N?<^SLr<=3D8A`9S8@OIULy!absAcZ!wwI~<>SPD(f@
z9cj3MJLO8>k8bXuPHHJ1uCn7>IR9Wskh4;;k~5PS;xEnJ)685&h^N`%$<{t`b2$z^
z<~{-AV#UJQKMNMU8+Cv6Ea_O^6CLY1vvGaSz{l13?3?$#yGxVc?+4G>N{2DSxeNDJ
z@5SSsTjk+n&aV2M+y!^6b>d%Xf1|xaJB7^%xcsS$IiG$Mn+wmO_wlYBb8nMjf12UO
zJb+|h%`)O*Yu@Axss781RnME!F$&3@pOxfOyROr`&B&v1=3DEn1FsJ`Gd?N(+V<Zax}
zH!$@&Z;zEdi@ERSSvhuy@2LvzPB1if;R`1H&KZ9cJ$CwgL@D1YAHdrrWbXvd9CB$X
t=3DMA}%J=3DAZRGUoO7cw^k}@8RDC2CkYoe+TFp{JkGc;aq0G&6%8^{{jgy%S-?O

literal 0
HcmV?d00001

--=20
1.7.10.2
