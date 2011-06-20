From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH] linux-firmware: update firmware for RTL8111E-VL
Date: Mon, 20 Jun 2011 15:39:38 +0800
Message-ID: <1308555578-31848-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <romieu@fr.zoreil.com>, <netdev@vger.kernel.org>,
	Hayes Wang <hayeswang@realtek.com>
To: <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:45609 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753144Ab1FTHkh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2011 03:40:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Updated firmware with stability fixes.
Versin: RL6210B_RAM_Code_110610

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 rtl_nic/rtl8168e-3.fw |  Bin 2804 -> 3248 bytes
 1 files changed, 0 insertions(+), 0 deletions(-)

diff --git a/rtl_nic/rtl8168e-3.fw b/rtl_nic/rtl8168e-3.fw
index cb494071d0273c7b3102b97552f4bc7b756c0e17..0b9f907a2acae6818c1478218e10e440b4fba900 100644
GIT binary patch
literal 3248
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

literal 2804
zcmaKuS!|S56vyvuXDEwdX=z8WolZ+xrAP=!Vq#-Nc`(M9m<Srf13vJiQ4@-BIfa&`
zMS>d`6R?UeXp0DaGtxc~Ow<@#AOWSxH%JAQw21-A(sulv@B5~F;_~q2-gE9*{^x(s
zJu}W#sjG16T$w8jxh!jsTkSNBzTQ=$cQ3}A^PHP)Mp<?7_Vv!~b}qHVg}!E6^Ecaa
zhfmgFTN>J?u(?)9sXFmvo4q7vYMSp0SElP4GJ2TRHD>fnTi?j&5!S;mW%Q`YZ)UX1
z<d-uVi<N20Wi-K>U`?@(F3G5{4)4oon)L)SwfH$4IpT&j{MJ>M`xqL)kaQJVo32nd
zmeFOlj%KvBf^`JhR%G8V;^Xi!U9={r)D{;VUM=cT<8VP#+eHtdi(eBhi;2c;pA)Sw
z?jICg!`}SjJ4FwwXqzXR-!8hN4f{&uyl7=BI_%n_I_ypNR#dl3v>n|y<p1iBXwxat
z3;RXi!KQ6MwD(=n?u6*u&7v#F*;|9m`d%mxB1?<tAT|?NyVr?s$Jbp3TSjy@`@tK+
zJ+hL+YU~}uj{Wv%Ov4(=Nn(1}1Dx4T{7QqpakQ4Y5{;rIU`!bYKZ`!FS#&A;k^4li
zCyC>Uc2d{fS<x&!wq3vud0vy~Li71fbpE}>v3-~5`}i!j{kNhoMEoaJi&jVcmvJ@=
zJMWU{F6zpG?OF=Ha)DgTI|2MP5x?2sDxRfkMQg(|4@?$kPBG4$JL1%d)<xo61@m~E
zxuSC;XRpG4azyk7ybaw1;|9@f#5Vr=o)7r`tzL9F_$%@2rnal0JQ=xiTA;fg)lCm{
zx1zckfo^YA5X<-Fek|Uu=7?@47|`wHzT(*CxUbe<xfgn{6h4-KYlxgrgJ=I_^lAEM
zIr_EK@ezI8iy!^ySnIpl{|TonME4Adj?zEHT7RHctM?}L#^~Lyr@+Gbhar|uYI}5^
zXtTxG%YBh!UWe$9&mhxJ)tmW{JGe)CXOEN9!}i#5aBd|}pJ?U`-&xUfVC<)-(|kL2
zh^_}q`Z>`l1<_~W*uniHmDrx+>lZzL1Ra>VW1@S(WAEn>y>aXw(c|>!R`T@0-I=85
z*)VR=_XxR8UBMrWMeJ7p5Vei%;X6UUk8<DO_Rfp`^1J9C#7x6q0zR|g@ZkGmsP{O_
z(;uU(N%I4%^-@O@@1*YbzLY!j^(~@zWpD4Tr+xi4c&g>S!PA97V$BX$YVvWsCi*&Y
z{e1U}u4KQMyY8F?Pb-6at+u;39o*+;<AfR0F$o>^LR{0uPx98b1U1^5Zp{-DKAPz1
zI^xBt`_mkEIUL~Xq>dEWYw#UDi0ypQmazZL_H%e%P_(7C6!lCu+l$yP4Bkp@7<VIi
z7h&5vKz?$L&lGYb;Hnxwk2AwkjgMC%dWAmE(ns-x=m*3$t~$w60*9^aJBX72-wgA;
z6=180_~t_2o4h&S7oJPtdEA$nTksu$-+$x7n?Nst+n*(tgPtG9H&JwAb1*Mb?Ysdy
zkMLu@m%wke_-6|u_&Cc_XQJpA;mZ6RH5ShX76m-GkD2kD*^EC;&DQrL;2-23%|40V
z=DW=&<J_ZHP4CEIcXfa|uF?mwP(F%02{|6hUn3`wE$@g6_^=re-@u#UtYr{i^foI-
zcrV76=^SsW*|5;FzRu%K2ycemu_}6Rzvuun$>b#Qi*bsx#&X;uM+^NsM4Y}&<Redx
zFHQ~qoVpzJ^$hEAW|qyHRZ~Q()-VIWbF!cJ1~>im{8Vz-`~JVLoPJ1tB3k(VpR;cq
z549yM4sWVk$qW8X<XXk|Uzp~?dm}aE3&HPpjQ6?tvjF3!v&>}THF4M7;BBXOiog9s
zF>vEIZ8AI_W~DZNKJ5$Yws{?ujYFHW#^(WkJG!`Y<!z7G1&-)U&tto>L9`)HUyyrg
zPV@=(`B&iJVbPyF^k9Cnhkmj>Slwfy59L$Fqy2}R%G%R#hg|&c<--4_g@POZZ(97n
VdHX+Uxf?6kf6?+D|9>1#e*sYqwB!H)

-- 
1.7.3.2

