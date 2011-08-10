From: Hayes Wang <hayeswang@realtek.com>
Subject: =?UTF-8?q?=5Blinux-firmware=20v2=201/2=5D=20rtl=5Fnic=3A=20update=20firmware=20for=20RTL8111E-VL?=
Date: Wed, 10 Aug 2011 20:22:58 +0800
Message-ID: <1312978979-1808-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <romieu@fr.zoreil.com>, <netdev@vger.kernel.org>,
	Hayes Wang <hayeswang@realtek.com>
To: <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:59996 "EHLO
	rtits2.realtek.com.tw" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752894Ab1HJMYG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Aug 2011 08:24:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Updated firmware with stability fixes.
Version: rtl8168e-3_0.0.1.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 WHENCE                |    2 +-
 rtl_nic/rtl8168e-3.fw |  Bin 2804 -> 3264 bytes
 2 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/WHENCE b/WHENCE
index 4b88f1f..a463417 100644
--- a/WHENCE
+++ b/WHENCE
@@ -1626,7 +1626,7 @@ File: rtl_nic/rtl8168d-2.fw
 File: rtl_nic/rtl8105e-1.fw
 File: rtl_nic/rtl8168e-1.fw
 File: rtl_nic/rtl8168e-2.fw
-File: rtl_nic/rtl8168e-3.fw
+File: rtl_nic/rtl8168e-3.fw (Version: rtl8168e-3_0.0.1)
=20
 Licence:
  * Copyright =C2=A9 2011, Realtek Semiconductor Corporation
diff --git a/rtl_nic/rtl8168e-3.fw b/rtl_nic/rtl8168e-3.fw
index cb494071d0273c7b3102b97552f4bc7b756c0e17..43d1b8641fb09d2f8dd9199=
8ed78c1deb7c71a7a 100644
GIT binary patch
literal 3264
zcmaKvYiyKd7RR4XJEv1F2Cx-|%P_rAM4+9iSgT*G$Qn#^V@Nhxb+hmRKA3FcMoAX$
zr$R?<l^E|avDV%FqB0d(q94pMd@!2qCYvonBD=3DbIr?%kknwf+^%cW)foq68TS3{iS
z&3T^loXh{*p7$N+oO^Kh@A|U6eY-YZzdh5H>B^=3Dvz1=3D-M-PtT>_Pd*BdA)N<x9!f}
zo@{3G_HDP`wf(jScJA7q&1QPDnRIs3%{_fLXEW{v=3DT@s*=3DG3_sS1G$R^r+kFv=3DM%=
{
zOTl-)uX8SNZlwvO)x}14I@611YPu%d{v+9?4xO|^wmFoIBQsrzt2(LLHhHPPMjLtF
zcP+Z3KdA?yZckD_F#1GN4?zz;nAE@6{>h{sw*5m%t*dL%xJzn1v>qCV&SjD+(3v-r
z+6euWJ+V}MIDEt`&hXjMy0nU+9}Ep{nI3OirVjs;MiWUrYqXNohIyXfY;-|VJB-5L
zZFCyB<^H^31r)tzqjSg^#oi{P=3Dxqu4FB?U#iX(!-fx&pu962RdG0~Z=3Dq5(OZsfg;R
z=3Doq}%v}jA6Xq~OwL`OAT-y(VseAA2lRrFu*hXc{#GosH9Ba>oZ6ip4mLvA?Ad(QKo
zkMj0o8@bP%=3D*MHC1II-tkBPpB%<z=3Dx_)DUNdeQbl(HrqO-p(G{8SYE$6FJcmGV_e?
z5M5*xdy7MQ1T3XS^o%|v`U=3D!+JcAGSt>`;R(HB^kE(rbObuAa;myyHH@~CgHt_t@J
z_zupC4xyXQqu1=3D$F?8NoO&kI7c8ac@WL+W#){|4Bvuj1qH~75epBHUTv*z5f9zti&
zy`m$;6KfLvcU<%-%k`t8*&fk`S?_ay=3DyQ4%Hqp2JfXV$v^zZ9MH`;og=3Dwa+M*!mUG
zzjcZ3v-M}957hkc7oFcK+Dg5L!5L$}iL({R1>bnPZNxSWj>$H^w|eK1OAvp1L~ms_
zjES>&hiFH57O*#bYif4Z{KO7<>5SMpw=3DrUeT&<0qJ!0{YgA3%nd=3DZTIi#{FZ;@B=3D=
<
zum5(7_JTi!UV+%oh5H5UQ;R+Ce3ZAu^DaesS9{)T)X{8Jb*Zn}OAkhP*MI@ubM#aU
z*|rgCc#8bc>&@gNL(FA-{u&!23*gg-iC*~BxZy44WgNXRY7gx$us%ahZxnsCEILR3
z)nfezv0A(riMNg!Is7ZIaK0hLa)8+8Un@FjHmLhFKCV5$EZ>3LPSJG{x%-fF|MY!z
zU<b7Vf1AmIvG7aLPpEJ1i0Com{eoUN$$T{OB){bOia95S^0T79#cqZ5u7&h7eV1~g
zU*0bI6|#qTj!%FUUJaAQwTf5+Y!^NuKRM!K){|fGoJ1E}rfa^=3D9s(nA+WZ-IoBhl5
zo8{$G;<ntx>4S+2qW=3DSL@U`f@|EEsaNYNvw(joseXYglDrik90pS=3DLR0s5wsxP#?>
z-D+!M9<+Y4^;Le|ZtH~avkumlr&5pT%1J2sSp}VdJ{IB#9vAHk{pD|Bmbyf5q7TN&
zQ=3Dv}u1o^gjV#IUoDe6W}`a-)g5nZxZbT8*~)+5ANq}R{VU)8xAAns1;#re#i!9^`C
zj#li);@oA}TsITSlD9Z{Xg1mRki9O9CzL(CM09;k_Gx50yx*A*MW;4+pSAm@nk&;I
zw^QJ+VQFG*ch-TkqV@P{$5-%rm_y`)CU3`bYr2=3D1tEw*8n!x(KZX0o%E<JAZ+!4{W
z{G0B_d#{|21o_wthCIC#TSMP73pIT6z_*XH>3O_o)^bjc*456zkN~q`$bZ8bve!k=3D
zz-M+wkum@4YiHytL9TLk24*|kz}e80=3D-cEW;ru+e+AN;%^K5y{mEa@){oRk9RK!jk
zJ*)fJ1a{9+kGgPwhW&i@oZ0<7MqiHN)A5+yi}c6+%!Qqmh(E?$mC?QYsy{Dr-UQFy
zOZV;byhZe!Gn_y3*t^Z%t+}G;YU((G&Bel=3DILFvq@0+h#_!iSeX3B6BF5v_I!>k=3DO
zu{ln)!3W>B-M;q=3D?V@Ms1-n}plDm6;0p``r|7-aCT=3DXSoatU|MAD4>$2ixU}k7qWV
z-<q!yz6`?&a-qbMBj;t4e;9w*ypq2>{$lh(Wsi?-1-<buF_gQw>+tW;T|WYr0s7c#
z*yC$hy{n07!6MOv-02I+eF54%82L5<Lv3&0CWg)Ki>tvj{3p@R4-=3DRAxbjzs%kCw+
zf9zcuY~{XV?uUxpErtu*H-Kx%`iR<ADSYeS;t{YQo0|~*8hrNcW4X;+9@Ad7KGgXL
zooX*4SEa<Tn0`3b;=3Di48r@;)b#GM!YmYTzV^*)0Bp<lEgTmd!eX%oGhb#XU2-NH9v
z0H1noJBkfkp9JrnqMM6xi^0Cz7eSBq|72hLK6T;$fl9?W6w>y8p!SV#{{uGL|A2P?
OJ^RD|0{iy%zwZF4*F!x3

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
1.7.3.2

