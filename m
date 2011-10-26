From: Hayes Wang <hayeswang@realtek.com>
Subject: =?UTF-8?q?=5Blinux-firmware=20v6=204/4=5D=20rtl=5Fnic=3A=20add=20new=20firmware=20for=20RTL8402?=
Date: Wed, 26 Oct 2011 21:07:05 +0800
Message-ID: <1319634425-1529-4-git-send-email-hayeswang@realtek.com>
References: <1319634425-1529-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <romieu@fr.zoreil.com>, <netdev@vger.kernel.org>,
	Hayes Wang <hayeswang@realtek.com>
To: <dwmw2@infradead.org>, <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:52710 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933000Ab1JZNHm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2011 09:07:42 -0400
In-Reply-To: <1319634425-1529-1-git-send-email-hayeswang@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add new firmware:
1. rtl_nic/rtl8402-1.fw
   version: 0.0.1

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 WHENCE               |    3 +++
 rtl_nic/rtl8402-1.fw |  Bin 0 -> 1824 bytes
 2 files changed, 3 insertions(+), 0 deletions(-)
 create mode 100644 rtl_nic/rtl8402-1.fw

diff --git a/WHENCE b/WHENCE
index 3d4dc0a..555008e 100644
--- a/WHENCE
+++ b/WHENCE
@@ -1673,6 +1673,9 @@ Version: 0.0.3
 File: rtl_nic/rtl8411-1.fw
 Version: 0.0.1
=20
+File: rtl_nic/rtl8402-1.fw
+Version: 0.0.1
+
 Licence:
  * Copyright =C2=A9 2011, Realtek Semiconductor Corporation
  *
diff --git a/rtl_nic/rtl8402-1.fw b/rtl_nic/rtl8402-1.fw
new file mode 100644
index 0000000000000000000000000000000000000000..82fa35d70994dc679a481dc=
946d8985cd2f7bb3e
GIT binary patch
literal 1824
zcmZ{lU5J!r6vv<WSa+gg*9+0Y<IcrGYoWd~*cx7qq_P+G0SOrfGv$VwTP*9c6j+_i
zAV`hG5+P~I(Tj|X%pw!qyPyx$$Uy93y6Yk;v5O#S`u*p9Uv_w92hN=3D5eV%j9|9?K7
z_YEP0sp*LaR!7wpm3p)?T3IPqqE*$=3DRh0@y-Cu+M)434Nh3B_TPt+&3?VjBITwN~p
zXic=3DbK0dW`=3D9#H-HCkI8U3-5u9B2*8uTOu)FyxZS$-6u(SnA=3D3d3XugndlwnN5{;=
E
z_VBzZ);V-=3D^Y$z8UVja}9_g_ge2nJ?g8%4tbcki>ar1xc=3D7o>Uw`?_E7MYKuZ=3DN*=
2
z_KW!<>=3Du1xzVNL1uFK{FJP&-%`jYvbtQUM{o)ecX=3D0)iz&F?0L_HxNykv+wI5xI^W
zt;Ad#@GiioJU+*#a2mXZc@4Y8=3Dr;WBAkKc|I6TGso}Ro^he74P&pcvX#^*xjT=3Dlv5
zvw0rh|2)Qa_R6vsw~T$BGu5l}s`)v1bnE(%c{O7v+!8TV*Y8{AXRZ>z6Wf=3Du4=3D*E6
zo8O+qnAIK}B*!i#e5j@3J7=3Dn2kyygc?|@rRpHiHO3<u>_cxMhv{rtM8pNGI!KTrK&
z{sP<%pl8s#;5v<N!sDv+cf^6$UvB<BJ|83E)h2#6?^2R?39jKaxH2E=3D?Nf<QQ+f9E
zw5c9GG1tEqSVgeJMLoF*rm&jI<qPts4uiy2Z-+Kh*SdKh^XaNJbD%l>7OeDH`3-04
zQY2Q`JO8W*LwytOEVioId@<Uxg-35cy1jjNexL3+Jyb1)5gs;A?`8Kca@Knf2dGg8
z4!Vb1$uV$8wxbJ&StoOJoO-RGUazC?L#v0&(aYb(CKGR%J>izYExsAgY3Whool0hw
zbq=3D4Io*CP7&HRrJv55IAzBPQ;jF~T4Z~o1?IG*-uNj=3Dmb&0nhf-=3Dc><ns36t?~wU=
}
zO?Z-r=3D3n<-F&p^5N6e9paXdYbke{B@xY_r~Z(yewss0_Tb-a7-1!H6KK4}sw52rkQ
z$B@I|r1sJUxTZbsXZ<H}JILFKo%Uq67_IloKL_KyFN1Z3d<H&X=3D6<4n<mXq+zob_A
z51D)LyLT5%t@mMbgEQ&tXyvY6wBeWL_y)EY!A{R+IlGbJdmB7T8)6Qh!eI%u{e*Ze
z^fC0_ByYzzy`yPA7UDYshVW{eZ+#!Dre|8_N0J!jM{b>=3D>`b1(Rx|nc`M9V0PKEqZ
KkMyn5n&1B#>OCI-

literal 0
HcmV?d00001

--=20
1.7.6.2
