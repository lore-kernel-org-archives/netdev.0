From: Hayes Wang <hayeswang@realtek.com>
Subject: =?UTF-8?q?=5Blinux-firmware=20v6=203/4=5D=20rtl=5Fnic=3A=20add=20new=20firmware=20for=20RTL8411?=
Date: Wed, 26 Oct 2011 21:07:04 +0800
Message-ID: <1319634425-1529-3-git-send-email-hayeswang@realtek.com>
References: <1319634425-1529-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <romieu@fr.zoreil.com>, <netdev@vger.kernel.org>,
	Hayes Wang <hayeswang@realtek.com>
To: <dwmw2@infradead.org>, <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:52708 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932880Ab1JZNHl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2011 09:07:41 -0400
In-Reply-To: <1319634425-1529-1-git-send-email-hayeswang@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add new firmware:
1. rtl_nic/rtl8411-1.fw
   version: 0.0.1

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 WHENCE               |    3 +++
 rtl_nic/rtl8411-1.fw |  Bin 0 -> 1584 bytes
 2 files changed, 3 insertions(+), 0 deletions(-)
 create mode 100644 rtl_nic/rtl8411-1.fw

diff --git a/WHENCE b/WHENCE
index a9447ac..3d4dc0a 100644
--- a/WHENCE
+++ b/WHENCE
@@ -1670,6 +1670,9 @@ Version: 0.0.3
 File: rtl_nic/rtl8168f-2.fw
 Version: 0.0.3
=20
+File: rtl_nic/rtl8411-1.fw
+Version: 0.0.1
+
 Licence:
  * Copyright =C2=A9 2011, Realtek Semiconductor Corporation
  *
diff --git a/rtl_nic/rtl8411-1.fw b/rtl_nic/rtl8411-1.fw
new file mode 100644
index 0000000000000000000000000000000000000000..d9aaad151004e8853560918=
509f91d2329ec8f07
GIT binary patch
literal 1584
zcmZ9MPiS0q5XUE*>_my8ho;R+Oke)Asn%xqt+6)iWs#y4M2g_05erfeg+fJyAoef~
zRBYCUQl+Q|$-#@z?4fwF;6^C*CZ_bzVxn(rs>PP%64E3jSwFMyEnQvs?aXg}-<kQ&
z%<ug~L_YZN#DU>3+!r3r4dsTyAk1a+`?F!lQT=3DzA|FIU4ti1X9{(SDh(R?lpb0gt!
zkk1wJ!-eN_a_-v!hn8w0J59R8L^`FmBmr_p4vDp6&q@z=3Dd7n^`NVkImlho8Pk@F(y
zT*KF~{r|ys2|j^<-Iid}U{-2rGtqi%$7}0$YiE5aoz`(GV_&&Ek+FM;Ty=3DReV_V24
zkiQ`xMb05N%Nd(b&VP4#En|Nm*Ck^SvYN|4x3iu@$l+X@If%g}rS{;Ef=3DAZWY)Y++
zEw!T7)1ubm`d+m$OLVaBHtZj%eSy6csZ~E!J6i(N!@i2|1U7J`X4_}6?Od~MQf&&{
z&!Tpvtakc_+QJdF3t&oj$o;w6ks<Vo+I@0lz?HsJTRX2-TT~Nxy4-kxKC3nkE;X#y
zTYyVr|6;sfZNnF?({S4spu0bMK#dXkb}x_{?u&!5ey3k;5L?>@=3Dc{UyV1jA2m8Zbr
z@B6*pA8J1JoLZ~vGstnZA=3Dgi;eN4_Qdh~US?{)tU{Cng5X~%6>yVad=3Dn^b$GPpyx-
zO5{$lUw)zK3{L$`XLrMgXXyd8f#fX0&-v~0d};FSiud*UJ;!cpY>G3nuPF}o4>p~B
z(i-<*ogN%tq855s75a-DBz}}vD|&C3fpe}D)qcV@LT%H_^nOp`6QJYcJ&d{%pCr#B
zJ}(g?;tozQlL_Xqz+S*d+=3DC_V$kxS}#~M6-S;xj&KMoJ>%=3Dd4RcT4RZ`sjHtk+*}q
z-F_cN>EVdlo=3De>A*T5Z98*Rdkf|Fmld+v8vEzNBD9Lv7)hT2s)ocU4h`hB&VZOkge
z_sh!6vF5q=3D?Ql6uZsOL^-+Nqb^=3D-ZZQJZ^3Z654p){Wb6#n#~Dcl7Bp^%1*rmHT~$
z`mPi6ChHcy#ByKHwR{<l)LFsbxfkHJ1<#Aj;~I5uveFxBx7XDEfp7FD-_1R>$B5Cx
z{Qe3O``?^l-*5~)-rR&MHF+;1dTI3BXIkk~`{C8Nml3@@h`nW}TIV;+n0ZVegx521
zPiOHjGoM-S7yJt2F~24FHD>1bWvr-HBxiJmTAo#VxtiupQhz6(M9vidw{N^xlDxk)
fUTPfb?{DKxefaL~kW@X+j+y$K%v&cH94_)N&kqV8

literal 0
HcmV?d00001

--=20
1.7.6.2
