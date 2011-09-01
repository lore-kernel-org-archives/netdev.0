From: Hayes Wang <hayeswang@realtek.com>
Subject: =?UTF-8?q?=5Blinux-firmware=20v4=201/2=5D=20rtl=5Fnic=3A=20update=20firmware=20for=20RTL8111E-VL?=
Date: Thu, 1 Sep 2011 15:07:12 +0800
Message-ID: <1314860833-4000-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <romieu@fr.zoreil.com>, <netdev@vger.kernel.org>,
	Hayes Wang <hayeswang@realtek.com>
To: <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:41325 "EHLO
	rtits2.realtek.com.tw" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755420Ab1IAHH7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2011 03:07:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Updated firmware with stability fixes.
Version: 0.0.2

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 WHENCE                |    2 ++
 rtl_nic/rtl8168e-3.fw |  Bin 2804 -> 3552 bytes
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/WHENCE b/WHENCE
index a47b307..3803906 100644
--- a/WHENCE
+++ b/WHENCE
@@ -1657,7 +1657,9 @@ File: rtl_nic/rtl8168d-2.fw
 File: rtl_nic/rtl8105e-1.fw
 File: rtl_nic/rtl8168e-1.fw
 File: rtl_nic/rtl8168e-2.fw
+
 File: rtl_nic/rtl8168e-3.fw
+Version: 0.0.2
=20
 Licence:
  * Copyright =C2=A9 2011, Realtek Semiconductor Corporation
diff --git a/rtl_nic/rtl8168e-3.fw b/rtl_nic/rtl8168e-3.fw
index cb494071d0273c7b3102b97552f4bc7b756c0e17..525f467e04229c52fbc3867=
6b2bbdc93832bc945 100644
GIT binary patch
literal 3552
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
u
z?4k2k_VU<^(+lNYL2S$Djo%YPshztH`wrQ)gZR=3D%A6pH77}T(GR}<5`1)_(!)8~`>
z5pc)e$hQeTRQL96V!qjZaT`7j{8se6qr{~_T=3D`qXW%rWZKlZNlH*?=3DH_x%O#7V`_;
zcjH&T^%1qLAav{B!ZCb-H#a8w5&qe?kL5ORc}xeqHKEL(k*V||d=3D(^yh4jOP#^Bp2
zcM+eV6}j`G-%_*KkM^5ycA>?<HuE<t+Kun&DPkSRpKjj0na~e%-o#y1kx8>g#=3De>S
zC7}%GCR0S_%joc_cYhfBIC}@bPv1rR+HC&_{%-Q)(<|9#(T7+Uc2e8>_%<~e^lUkf
zUR$3<&;6pC3JJ@l{jXU79`F9#zWSZ)!v9O<vU3Qe?f+8sKal-T+GPKeT7vIt_lmK6
G_V+)RiLX5X

literal 2804
zcmaKuS!|S56vyvuXDEwdX=3Dz8WolZ+xrAP=3D!Vq#-Nc`(M9m<Srf13vJiQ4@-BIfa&`
zMS>d`6R?UeXp0DaGtxc~Ow<@#AOWSxH%JAQw21-A(sulv@B5~F;_~q2-gE9*{^x(s
zJu}W#sjG16T$w8jxh!jsTkSNBzTQ=3D$cQ3}A^PHP)Mp<?7_Vv!~b}qHVg}!E6^Ecaa
zhfmgFTN>J?u(?)9sXFmvo4q7vYMSp0SElP4GJ2TRHD>fnTi?j&5!S;mW%Q`YZ)UX1
z<d-uVi<N20Wi-K>U`?@(F3G5{4)4oon)L)SwfH$4IpT&j{MJ>M`xqL)kaQJVo32nd
zmeFOlj%KvBf^`JhR%G8V;^Xi!U9=3D{r)D{;VUM=3DcT<8VP#+eHtdi(eBhi;2c;pA)Sw
z?jICg!`}SjJ4FwwXqzXR-!8hN4f{&uyl7=3DBI_%n_I_ypNR#dl3v>n|y<p1iBXwxat
z3;RXi!KQ6MwD(=3Dn?u6*u&7v#F*;|9m`d%mxB1?<tAT|?NyVr?s$Jbp3TSjy@`@tK+
zJ+hL+YU~}uj{Wv%Ov4(=3DNn(1}1Dx4T{7QqpakQ4Y5{;rIU`!bYKZ`!FS#&A;k^4li
zCyC>Uc2d{fS<x&!wq3vud0vy~Li71fbpE}>v3-~5`}i!j{kNhoMEoaJi&jVcmvJ@=3D
zJMWU{F6zpG?OF=3DHa)DgTI|2MP5x?2sDxRfkMQg(|4@?$kPBG4$JL1%d)<xo61@m~E
zxuSC;XRpG4azyk7ybaw1;|9@f#5Vr=3Do)7r`tzL9F_$%@2rnal0JQ=3DxiTA;fg)lCm{
zx1zckfo^YA5X<-Fek|Uu=3D7?@47|`wHzT(*CxUbe<xfgn{6h4-KYlxgrgJ=3DI_^lAEM
zIr_EK@ezI8iy!^ySnIpl{|TonME4Adj?zEHT7RHctM?}L#^~Lyr@+Gbhar|uYI}5^
zXtTxG%YBh!UWe$9&mhxJ)tmW{JGe)CXOEN9!}i#5aBd|}pJ?U`-&xUfVC<)-(|kL2
zh^_}q`Z>`l1<_~W*uniHmDrx+>lZzL1Ra>VW1@S(WAEn>y>aXw(c|>!R`T@0-I=3D85
z*)VR=3D_XxR8UBMrWMeJ7p5Vei%;X6UUk8<DO_Rfp`^1J9C#7x6q0zR|g@ZkGmsP{O_
z(;uU(N%I4%^-@O@@1*YbzLY!j^(~@zWpD4Tr+xi4c&g>S!PA97V$BX$YVvWsCi*&Y
z{e1U}u4KQMyY8F?Pb-6at+u;39o*+;<AfR0F$o>^LR{0uPx98b1U1^5Zp{-DKAPz1
zI^xBt`_mkEIUL~Xq>dEWYw#UDi0ypQmazZL_H%e%P_(7C6!lCu+l$yP4Bkp@7<VIi
z7h&5vKz?$L&lGYb;Hnxwk2AwkjgMC%dWAmE(ns-x=3Dm*3$t~$w60*9^aJBX72-wgA;
z6=3D180_~t_2o4h&S7oJPtdEA$nTksu$-+$x7n?Nst+n*(tgPtG9H&JwAb1*Mb?Ysdy
zkMLu@m%wke_-6|u_&Cc_XQJpA;mZ6RH5ShX76m-GkD2kD*^EC;&DQrL;2-23%|40V
z=3DDW=3D&<J_ZHP4CEIcXfa|uF?mwP(F%02{|6hUn3`wE$@g6_^=3Dre-@u#UtYr{i^foI=
-
zcrV76=3D^SsW*|5;FzRu%K2ycemu_}6Rzvuun$>b#Qi*bsx#&X;uM+^NsM4Y}&<Redx
zFHQ~qoVpzJ^$hEAW|qyHRZ~Q()-VIWbF!cJ1~>im{8Vz-`~JVLoPJ1tB3k(VpR;cq
z549yM4sWVk$qW8X<XXk|Uzp~?dm}aE3&HPpjQ6?tvjF3!v&>}THF4M7;BBXOiog9s
zF>vEIZ8AI_W~DZNKJ5$Yws{?ujYFHW#^(WkJG!`Y<!z7G1&-)U&tto>L9`)HUyyrg
zPV@=3D(`B&iJVbPyF^k9Cnhkmj>Slwfy59L$Fqy2}R%G%R#hg|&c<--4_g@POZZ(97n
VdHX+Uxf?6kf6?+D|9>1#e*sYqwB!H)

--=20
1.7.6
