From: Hayes Wang <hayeswang@realtek.com>
Subject: =?UTF-8?q?=5Blinux-firmware=20v3=202/2=5D=20rtl=5Fnic=3A=20add=20new=20firmware=20for=20RTL8111F?=
Date: Thu, 1 Sep 2011 00:16:47 +0800
Message-ID: <1314807407-1512-2-git-send-email-hayeswang@realtek.com>
References: <1314807407-1512-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <romieu@fr.zoreil.com>, <netdev@vger.kernel.org>,
	Hayes Wang <hayeswang@realtek.com>
To: <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:40790 "EHLO
	rtits2.realtek.com.tw" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756683Ab1HaQR1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2011 12:17:27 -0400
In-Reply-To: <1314807407-1512-1-git-send-email-hayeswang@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add new firmware:
1. rtl_nic/rtl8168f-1.fw
   version: 0.0.2
2. rtl_nic/rtl8168f-2.fw
   version: 0.0.2

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 WHENCE                |    2 ++
 rtl_nic/rtl8168f-1.fw |  Bin 0 -> 3024 bytes
 rtl_nic/rtl8168f-2.fw |  Bin 0 -> 336 bytes
 3 files changed, 2 insertions(+), 0 deletions(-)
 create mode 100644 rtl_nic/rtl8168f-1.fw
 create mode 100644 rtl_nic/rtl8168f-2.fw

diff --git a/WHENCE b/WHENCE
index eb7bdfd..2e79b26 100644
--- a/WHENCE
+++ b/WHENCE
@@ -1658,6 +1658,8 @@ File: rtl_nic/rtl8105e-1.fw
 File: rtl_nic/rtl8168e-1.fw
 File: rtl_nic/rtl8168e-2.fw
 File: rtl_nic/rtl8168e-3.fw (version: 0.0.2)
+File: rtl_nic/rtl8168f-1.fw (version: 0.0.2)
+File: rtl_nic/rtl8168f-2.fw (version: 0.0.2)
=20
 Licence:
  * Copyright =C2=A9 2011, Realtek Semiconductor Corporation
diff --git a/rtl_nic/rtl8168f-1.fw b/rtl_nic/rtl8168f-1.fw
new file mode 100644
index 0000000000000000000000000000000000000000..ffb1dd137eebeb2394acbfc=
f14c96a6091e73a06
GIT binary patch
literal 3024
zcmbuBdx+Fk6vyw*I>+72d~Q0quCou{ubCBXwSQKlFtQRMB9jc#KoE>FQqefNiaMJj
zT9yQ|83c*Dgb0O!yNX!)NB9a9U%%1yLCP$Ft-9^*^f_~XqigtI1DA8|d4A8i=3Dic8q
z=3DiEojm)0bw)qF59xiB#)F{wJ9sF^$^IXRg`XTQ0u%Ms_Q+`Ku{s;d(-7tWjc+QJu?
zEn2)VnM~AFPl;DgnUS12V@i$N=3DG+K%L!CNT;<9Zn4sCI>o%TjP*_9!89~L+lI9F;$
zadnY~Mb7-9iM+4bRz7As)Zr6%*bWYDqu8`(qpD7FvCUozpVi*1FA7R@O>IoSb|u<p
zbxd~|T^iHdA-!*OSxmd3{h$}1#n6k;uBMn?3iX$b9*gM}Xorhw08J-iz%I$<a^y11
zJ+U|iQ$+OMY{4Fy71ajOCS;Lz(V+#R1;&pQ-KHTwOLPHp^NTc!o<Lq7h^9A*Zm!3s
zjD1?PEQJia`ku1Sy=3D+TQ*;dg8?0$8kzch)iKP%cgO>{dp_18r+J4AmYR;G|#M&A=3D{
zF^c`+kRCGHTeR8e$D&_Co58n<819bf4>9n=3DXC4UW;C-#uQ{C7R=3DgNA~8thN4VGow8
z;l3C9;J#=3DI-#E2q275k&&#Q582Glc3baX3xMzj*X70jKZMeq0WeQDexIvCq}^bS6S
z&x-k?yQwEqEP5*{y4HI6hUn62(O#WC=3DhiT1`*337Z~Mt+htH4WL?;;kjOan)^fLY%
z(Z42&))^1(PxAS<iuNfNE$2Mz!5LwHvQD%VyI_}(TS0B@MdYdQ`>CdT-}9AuU8UbA
zP4|}Pt4s&})+)cZIcOw)bfoCWFkislu#d{ep+~l#XmLtCKRO?WzL~BNU8njU2AtVi
z^WTU4bDl3Zp0n71JZ}6mp06~XIyNG&g10%&(9=3D@t&d`tH(5ukZ;0&&@=3Du?gHX>d;$
z9X3gHI#^Ei^>eVQ!q0{E^ZT{*v59>cHzK0fkgX#}*BF0pX=3DddvvzO}wx(Kz7x%X%v
zEf=3Dl8{vJIE#)kOG7omqgQ_r}(?FM>CzXzJ_U2MmPHHEgHt>gT$O<ku?=3DpW7+IUPCk
z`HRVC^R^G0!nn_EHRt+9tbkcEyw=3DZ1p=3Dc2pa=3Dzp*CjUd<3eiDe3Akgq-uCddo||t=
S
zm~3{R*aMpda5RGNDKOQ+x8LF3bKX|_*u0*+Mc}l&jknNYJFce=3DOctjB8_PL9uiJ=3DU
zmG^5n;&l_yS%1Ez_991LPEmg|x>cfUYCP6d208W*`$wFz9&w`h+4(l@CFkFqNkO<j
z$i5GIbUFP|_TX_W>p=3D%|u%ylFG8aUT(Bn3IyLWnh2K{kl_Kpmw^D=3Dv9?43)cMMoUx
zeZYPIGiEh3vA6lPIGxB1ZwL3nay0)VdKCFecz2q0mKrLMgRLsz=3DeL<N&kpi@-?^f1
zzXYBUqL;p+H)lk5aIXel65TUI^fIyAcpD9CXV>GoGUPH0e^94=3D%Tn~SjoRB*l8=3D~A
z%GXG~2<Mz#;cFXqLUb=3DRv~kzYli%Sxem7Xw^7h;LaPD?K1)Nuenx5{@dpAI|FMVx>
zUSIF)$i3BI$nP`MXxQw|52A+p??lfWpf2@wH9ny(dt2--jI?>4ExHqb>;G!QMeM2I
z%FPJ9$Wi1ro9RPfG25%W0WJPJ^gMYRmy<8<Z3{!6pUlVR47(gX%(*s+-YD_kvD8g4
zBg+&${$1;GkIzyZAH(#2RuF)l7zI#!a|7PSTI!GAqhGDmR4bZ5X5T_PxAHOAm`@xY
zYTv+MXz0`KeKPpGK#YKyNrnAuW$&;LnBAUp|9~0)y#pDmV+lBz)dO#mm+x>H-vZ0K
zkGy@zTWYf~Omr@@Fvi~8SFl^e8{Nb19qimm=3DEnSvav#gN<7Ugg`E~9E7&dTLr@?xT
z^FJTs{}(HEk;S}k?hTgBqVEzn3%|H8^S%HqPW0l-%p|t^S!b_;6<HpW&F65=3DBd|Fj
zZ~F$$in|v($2yNMvCP+U-Q5pH>a_nEdF<WH>P}|+7<G5CqMdw~9*F)4Ui&W1zs=3Dke
zql|lYBOc0cqC?(kHq2-jchgZ*EqwY@(RsDZkm<<p=3D7`QpM{QQ@zi5AGOYML5`Tv40
z{EwT>I)_8t{^REVw?6uBJH$nDafY;*Um>gCo?^^BpQ<i+$U7Hv-C6tp8^gAL$oGfm
MzqYOImd5}71$?3tJpcdz

literal 0
HcmV?d00001

diff --git a/rtl_nic/rtl8168f-2.fw b/rtl_nic/rtl8168f-2.fw
new file mode 100644
index 0000000000000000000000000000000000000000..880a223f35ab98b5367d2d1=
ee788ac0c9b05d762
GIT binary patch
literal 336
zcmXw!y-EX75QUEk8YD%wS#>~kA+_0i?~<^j5w%s2yud<;R)L6ETFfJeRqT8MpCOem
z;a{vRY(+5f%(A&~_=3DYnxoI3z;eKXE|FTXqph3mLZNL-#~KJ}hGd*{?4HN@bw7lJ!3
z21jSb$z*g<c<=3DI%B_ZqkZolhs2ka|$pg@e}HxhD&DYQX9#U6cJtpRgj*M<^B?QsO#
zTX(Bnn{9J;qrRmLYKmB!x1tZmvFKODALB%HLAJ;ja+7=3D||DHtOs{Xt2S@eVah3K68
pbi(+!%m6bidzA}pqXtCe%=3D|h92o_7bN9aXW9hLp^-}iP7@DF!bO921?

literal 0
HcmV?d00001

--=20
1.7.6
