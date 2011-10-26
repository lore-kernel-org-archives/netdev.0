From: Hayes Wang <hayeswang@realtek.com>
Subject: =?UTF-8?q?=5Blinux-firmware=20v5=201/4=5D=20rtl=5Fnic=3A=20update=20firmware=20for=20RTL8111E-VL?=
Date: Wed, 26 Oct 2011 20:45:32 +0800
Message-ID: <1319633135-25799-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <romieu@fr.zoreil.com>, <netdev@vger.kernel.org>,
	Hayes Wang <hayeswang@realtek.com>
To: <dwmw2@infradead.org>, <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:46573 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932960Ab1JZMq2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2011 08:46:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Updated firmware with stability fixes.
Version: 0.0.2

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 WHENCE                |    2 ++
 rtl_nic/rtl8168e-3.fw |  Bin 2804 -> 3648 bytes
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/WHENCE b/WHENCE
index 01fa5ca..71bff0e 100644
--- a/WHENCE
+++ b/WHENCE
@@ -1660,7 +1660,9 @@ File: rtl_nic/rtl8168d-2.fw
 File: rtl_nic/rtl8105e-1.fw
 File: rtl_nic/rtl8168e-1.fw
 File: rtl_nic/rtl8168e-2.fw
+
 File: rtl_nic/rtl8168e-3.fw
+Version: 0.0.3
=20
 Licence:
  * Copyright =C2=A9 2011, Realtek Semiconductor Corporation
diff --git a/rtl_nic/rtl8168e-3.fw b/rtl_nic/rtl8168e-3.fw
index cb494071d0273c7b3102b97552f4bc7b756c0e17..42f9259b84eaf7d59fbe07e=
18d27828af1b195db 100644
GIT binary patch
literal 3648
zcmaKvYitzP702(cy~k@FEf6~}JnZ!Y93a?UlQ@ums7q)?q_m2VDm6(J_y8XwMWRZO
zO46h~4zNk=3Dghr$gnyQZ5B2`ViE~TjbfXea#5vi4`nt+rCq_d6<X%p?X2y8Gm+uzxl
zrPBy?rO~<f-1GRK*PU7CoO^2Llk3vm>$b01yQQ<evwdwU-PzIA-H}dnX1|Ado~?53
zUvBe5-CgO<4O=3D#U?VDR3*s*Q<mUOyvefpkMSLgj*YwursuY1k8Ms<svI#=3D&XMVEq}
zbeo*k!0&Jk@ZI-f&iT$QHKCNc_~15YdWp`8uF1CikL*H+PRb!$7s@7(nJ6Vxos?~x
zyj0z(H9Ws{^}4mk(<4x~%hTT({h_Bvp+}zb^!K*^k*CLO|FoyESiL5kr&Z7@XaYLZ
z>8U^`f9`1w^fdcJ$j^Sx)1MlB($mjEdd=3Dt#Pj5oM4E+dN3q22=3D8TRx-c>b}`)1Lkv
zI)xt}n#V3VDr0wGk6Zr2XKT~Ka%?@sR_zw)+1f?wh-=3DJf($gzOOP*HG3ix$K=3DXly`
z6#h=3D56YLj5pZ9c|(FA;>2Rz+lR6YGkcz)REK~GN^#m`xz=3DEvwM{45Fhbw=3DU08lCa=
<
zo{+!MXf^hX{@darmPiba7>pOKol|NU7oFTB<O5m~)j`o=3Dc<~9*`j}|U*3F`W8m_-8
z`Urf}i~mXVL-_r^X#OS9m-~@vV4oLl=3D!1t`f0Xx1z<V{y+lOuB-gTnKhednOijJKT
z-H%NFxai31qPZ&3LwiN<!{<l~d+5)?eSv*4BU(UameH-E^NeC|en?M%rBH*O(WgZZ
zK+VQW_;8<#{>Br1jdkI=3D(AR;k<znO}a@hHC)Hhi7hx=3D-L``1MK&`o90s|(g~blz+v
z4xe~eh_;QfE{L|U9vc^(ZWFy$9po+hs%Tw`HRq0XA3D1p6&)a+c&+G13DFlU*FO+V
zcZpU{2R`?OJ|~u86MftFn%s9q|FT+ijjdOT9>dOFTR$%P=3DXTLOwtiQ1N5%g>(b-L+
zP1L&|oN@MxiEjyV{-=3DT6W@4KF$5?Z)w|ZxhOA>!eL~m(2jES>Et7vO@=3DCe0^%PV%4
zf58rUSrM^wbxp($xoV4?Jxe^6gX`qII0eQhL|+VZab|l^uYYuic7wkGy&SP!4fk`{
zH_Q)s*P^@y0q;hXcSpc`gF2e6vM%*Cdk4tRE#94AfcFYL6-TytfEr#TKlFMX`RF9(
zB0j%^je$Av>BD3<d}>_%7V|QK-Y~U?cH~%JCa3p_9xRH^(0`R!|4OVD?-cRIn2}@O
z1`FrE2(b(i+w8ljwb=3Dl}1U~K>VwN97ZX3QMa*rYB{ucDr&{k>%{$`T}WA0m`r>Jk{
zgy<RKeV;!0fcdE5@y_#HV9tr5__FBZ*e$W%K9_!`?;4!w`EQ6`K=3Dvrl*-@~<t6;LY
zmJzFu?c6EylOaB4-Fu(s19Y)vy5{T3Q7{sx&7Wbn*}qA@Szb;Px8){5AB<iX{U><+
zPedR6j5=3DYXfgZV-3i+2fgFkIDdGuz2+4IrsrEgXcx4$@8H`$t)_gX*M`b)vO#n#E7
z&steqo(f%}OUIz(XBl)9`do;^e_nK5=3Dr6mTS!x$uPalksr(8_*9Qn3*;>2_21?oml
z)`fQCBD!F=3D=3Dx)wutVf73Pp@C0zshshOWZ4{7w40Q!9^`CjwbBK6WnFkTsaxalD7nT
zs59AjkX;qV6Uts%AiBCD`y#Tff#1nLh>qVK_^jMF<y@H_xg7_81xqb!yR(L_h*sgN
z1z-N5Fo($dwSgVWt?AxiuFAS#s|D*V-Dcu8U3%Q+xiz9|`8VC;yKkS5B>C74hAh1l
zUrygM3l)5`z_*99iCMg7+BhdiD=3DX(<NP^igWIyE$*;Uaq@R^-KWX%8S${D#zlB<lJ
zf!WUP=3DB#g=3Dc_a@>7tC{$&EmOWo-L1=3D0(|6e-Tl~Uh}cP>XLTPQ#qL$=3D5exU1+0=
SOr
zncd&R^yMHv9go?aqCcKsF6^v8{Bh>0i0;jU!Fhr6T6p$edTdX?n@7(%!})(6d$-xU
zHIo-@q>cmFoG<K&bC|vLzWJJlZ!t|VQ-&jV10V38VeP1i&2d9BeDHnV5%hkpMf5Vg
zVE5=3D;a`(vB!Q9CFzk$#9L|<nn7jW17a-rzQ*e;fWc&5Yot@tY7%P^cH7fLJ{a$Yp~
zXYhy3+xg4lFHSF%b_KC5p*P+phGIK+9sV7<s|Uc+OCMVee;w4Yd{-0GoOz;0xYOs7
z`yBM}-pIEJ7%F@FHZg2=3DU)%wv{$Gi{cZ|3+h%0-Wxa?lC`^Vmu{wD4_=3DDsh_-D0?~
zeJ{BBtdFQ|nZmdJ&7S}ZvYAoQPrzs2K9<|8<uMh=3DR)so$M5o+~$dxHE%%>kN)(78C
znM+`XSK!WzeoM{ZKiY4;`GpsQwi(_o(H^j;CW&<nJUzU7(;*IW-o#y1)=3D9BO$G(~T
zMWGJorc*%YE7<U<cV8I$7<-4jPv1rRy3+UMSy%2vYP!+tMP2OuXZ*&ELEnxO+eYlH
z#OF{AaeyWI?k(5(?f<@er+L3P>eEB+^WUczz}1YsJTdNk7+dfSW9dWDlkok`^bU1-
z$kxZvT_w69pRk(Q|EGD-lRaP9SH8zx_`j@Fat?)*{V%Kh*Rua(8|?pBOYr^f_M1rX
=46`ws#u**yRN

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
1.7.6.2
