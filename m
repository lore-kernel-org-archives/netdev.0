From: Hayes Wang <hayeswang@realtek.com>
Subject: =?UTF-8?q?=5Blinux-firmware=20v6=202/4=5D=20rtl=5Fnic=3A=20add=20new=20firmware=20for=20RTL8111F?=
Date: Wed, 26 Oct 2011 21:07:03 +0800
Message-ID: <1319634425-1529-2-git-send-email-hayeswang@realtek.com>
References: <1319634425-1529-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <romieu@fr.zoreil.com>, <netdev@vger.kernel.org>,
	Hayes Wang <hayeswang@realtek.com>
To: <dwmw2@infradead.org>, <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:52706 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932880Ab1JZNHi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2011 09:07:38 -0400
In-Reply-To: <1319634425-1529-1-git-send-email-hayeswang@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add new firmware:
1. rtl_nic/rtl8168f-1.fw
   version: 0.0.3
2. rtl_nic/rtl8168f-2.fw
   version: 0.0.3

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 WHENCE                |    6 ++++++
 rtl_nic/rtl8168f-1.fw |  Bin 0 -> 3136 bytes
 rtl_nic/rtl8168f-2.fw |  Bin 0 -> 992 bytes
 3 files changed, 6 insertions(+), 0 deletions(-)
 create mode 100644 rtl_nic/rtl8168f-1.fw
 create mode 100644 rtl_nic/rtl8168f-2.fw

diff --git a/WHENCE b/WHENCE
index 71bff0e..a9447ac 100644
--- a/WHENCE
+++ b/WHENCE
@@ -1664,6 +1664,12 @@ File: rtl_nic/rtl8168e-2.fw
 File: rtl_nic/rtl8168e-3.fw
 Version: 0.0.3
=20
+File: rtl_nic/rtl8168f-1.fw
+Version: 0.0.3
+
+File: rtl_nic/rtl8168f-2.fw
+Version: 0.0.3
+
 Licence:
  * Copyright =C2=A9 2011, Realtek Semiconductor Corporation
  *
diff --git a/rtl_nic/rtl8168f-1.fw b/rtl_nic/rtl8168f-1.fw
new file mode 100644
index 0000000000000000000000000000000000000000..10b3885281fd2a3d41bb436=
c238c2cf69736d32f
GIT binary patch
literal 3136
zcmbuBdx+Fk6vyw(I%nO?TGLf0*LC*c`!%yZTJ4{$ER3u~h{z;^G!TTMj8rs^Zc8~^
zB3f4e$Yu~E&JrOM1??)*>yL2DK=3DJikT_0r364<Ki?oOXG_cuC*|21$q=3Dbq>HoO|y5
zjdRYuwr*`hYJS7ZGgB**vy!vsBvQ%Q_48+^Qt0frlyxoY+>>tElKJ)Z$%j@hd+5oP
zkG!&K^~zK#xga$+QJ-8`KWE|Gd2WYu6V#1$>Rg4(^|%DI!!34NihQ=3DKLhfFTI2Slq
zX+{Zk(biSY{9?(1ui4h#W;@p5lW^FM3T<Q9^yXr!PV%wMUP?x5DeHqsg>G()>&LD_
zhi!`MCq~!C^>RqB8GR+LgV1}SC!l4}lhA>-xSk62r;Yv)*E7&Q7uNvVm5c+sBA?5V
z%P<#XaSEoW=3D+(u7Jv1k(t)gwnqP?PHBcc)GCyMUSkbhWo1#<I?W<-BM-V%s*y(_w{
z1)D1NU7}TKWZ1P7%ii;{_lsrQMO(4^(TRT7Ci?bK(eC-8JF#gwFPhyY`V+CTCFC;t
zqG*Rv><@<Yd!wbI?M7c0{Sev?zITb?{u2En4u1ITb>SSmuhrT)h#hgtn?)P2@7&BD
zEF;7H5ca_}(KNmZYR!)Fd=3D#H265tG|XOigTZuqQdEqpha`zMQD8{+$td0%uCwk_x#
zd>Wti%SHE4Pqa+*QcQG<_3~-awe_My`hCvrVb0$1#KhnBv&{~lFQ<vlF#aCVZ;A7^
z@n=3DN;o+;X7Jh<N|<linjtXj01^K1cUl>Lz=3D(Ms%sPkh`OYU>?Jo*KWOXS$a>Ut7@C
z`hCiD&w9Sjbl~r<^Lv|v4Dn+VMJI;&0``V|QXvjKvi(epQ|bB1g*f!hbS3Ee)%P&q
z%(j^Se(dk}e6{hMMKkh*@%MPX)_Cf82YDU5&2g5VR#JDCevF5ng>C|8aE?Wv8jSA(
z_X5#zvqTqwrE|ESgN-$QF07xQZ=3DsKE?8CTG5j}@&D>(+H_;c%GR<1C6`97eFQtOnf
zxAw7W(HiWp(vx6nh@X5>diV|XOe@$n(?j}wpV?l)c6wM-X#3Vy&L7+KdHRI@=3DB$y^
zk+YD$jC?k4`>`oW_}o@=3DzHh_|m?gt&{fw4~4h2Krm;7bqzv)}Uod8R~9n1H&$k%#q
zzD;1V*}Y>AY!<+g0pDF<YJ%_mi+j&`TkTT|dh!khr{&FDLWk|NVjY+)PAfK+b9zDd
z4t{msul11E%|K`U`IOp+I{MN{{q5*Bif(T3SkqbL*x&3QajJ^q#PGB8ZQDoAe>js!
zxc`>@F!t#3`orwO<5<>%KIULekJn{Sh#sQHJ@^jp_WCUPpOM)+GNQ@L?47Z9F5M+M
z;b-0l>_;$TRzn+mn_r95kKFL~aW5=3DK`wh{<$Tz^d-&jYfp$0kF>XLqb+d1>xNY4*n
zD*D``;F%zL>LYsdyXY?N)qST#_l^-gP3#`tM#I`aaC@#SxeUV})M?+cH2v(M_MQ#o
zBj%m*WylxhoOA1aZR36s-A4^Q+_mH6clb`<1C}k!rJYaQpHGDIic-_v<-B(zM2FMY
zcIfD4Uq}9}218+=3DrAEVMcYY)_w0tJ|`vK}wUsvW1b=3DliucVVK<^J3B6_*?%s87^Ya
z16O`V=3DtZ6)x7qCa9xP^imN%foe}^6*Z)P3&65h5X^!eI+Y|gOD(}SFAo9KlK{~b$T
z1T(TM?^f}5ZNS|=3DO9^}o)BjmP0Cr+Tp!Vhlyp4_2pSViDx~ZvAG>Oc<g?4V$ylZ)%
z1Ux?W4GhMHKE2*2i_e3^2$-34*uQS}4*P)FEuQ=3D9%=3DoW;$XI=3DAz`?8@c!s=3Duhp=
YG&
zSl<2Q9Y)?tn}u<rOB;AY?ah50yH&i=3DMRw0)=3DZ^UA-~Pkg$7=3D4l*%GJyDeeUrnmMc=
A
zz<P}HKhA8Gvf?LM%=3D@-duxt~3fw(#N)x(+h6<~3qCm&-bvHgm5^ekAB6)@TRF`n}X
zY!1lV%S;a8?!}L>j^j%#^R--8z5*k4+W(9K_CaQKH?#c%bq}y&{d||Mi~b2-`z|fN
z%-j>BihFh;5y~&3L*8#T%;-RPH?5Zey;OQ`XWCxFodCP_GN6}>kVhtnR_x)tIFHOC
za830+?W8Ad5x#fUFYr}{cdG|{g}2J)<;_OXMsfzr=3DwViLiDCGTx~7Rf+!eE#wEw*2
z(2mCc><j-nUHD%*mvat>g#DK;{6D_+A9{?7=3DHra%FuxMky?e_r_k6lOa+7y1?gn%A
YKRb?Xxy#)!z8s$a^tN_dn%jT>0`Au}Jpcdz

literal 0
HcmV?d00001

diff --git a/rtl_nic/rtl8168f-2.fw b/rtl_nic/rtl8168f-2.fw
new file mode 100644
index 0000000000000000000000000000000000000000..c468b8439d7fa5cc926ddc4=
5c2f317c8a2cef384
GIT binary patch
literal 992
zcmZ8gJxo(!6uoWft%gCCicbj?C_fsZ?^QrxstD0RqaltYUC=3D}&!5E{7aX4&Zl@JGm
z4u;i4I-4-iMRX-`^RG>C@`r&05V7^#K3+s$a&zvv_uPBGzb7Jc^VUSa*VligE1h+_
z-R=3D_!&rPNKQl7`0eHUp(+9er1*OyMaL)p<&=3Dd-6L$1i6+&mHi35@~lZ-81N&lv$A`
z$RUA9Tq<jlAQog!5Mw+gjf~5UP_<oyi4u_T{J2<M)D3D)+e)oQ4kAXIlQ?ScIe2O~
z;o$2oZW&HGC=3D(A5-xK!}KM;TC9emu)e=3D=3DNl@R_(R4vNH*>u`L$Izu?aW=3DClol_=
($z
z0WqxDJgd|bD+<gj@{ENy6h}gekold8-oPJGWCQ=3DU;yM($qM~$PF`c8nk-Vg6e83oW
zxxKN6e(cfS*o<PHx;LD^n5TY8@r}J4^4tr>&sjy~2iMB=3D7?wBbuPCOd3v<@`0A~ig
z+2>m|tmT>(*!yrokzj3Zm3s2>F~xD))0pCQg!?uByW&E(qQ?Ab#og53`dapE-cvuq
z-VM|hUnyp|kCp|+#y-Vri_d#4_s;iQgIuf6J<GlI{iNlhtV{YlSZ}mV(Y8CU$o1Nc
z_MlI@&%3P8HQ(<D`gHg_!rTsP><rensk_QOlACU+Me*#6V!-N`6~l~&niTQp-0v5j
z*RUdXRMGiTvBLU1?`4JBCEi7H%CB2n=3DNUfXS?%yH8NZWJWJ>I}$a~@04wa&OXDWRE
vb;LsEKW=3DX@c>5yt60Yj%3l@*iL>wts?4NQNtCPwv^Xuqaj`rAoseive=3D>I7Y

literal 0
HcmV?d00001

--=20
1.7.6.2
