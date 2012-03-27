From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH firmware 2/3] rtl_nic: update firmware for RTL8111F
Date: Tue, 27 Mar 2012 17:21:14 +0800
Message-ID: <1332840075-5991-2-git-send-email-hayeswang@realtek.com>
References: <1332840075-5991-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <romieu@fr.zoreil.com>, <netdev@vger.kernel.org>,
	<kernel-team@fedoraproject.org>, <linux-kernel@vger.kernel.org>,
	Hayes Wang <hayeswang@realtek.com>
To: <dwmw2@infradead.org>, <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:58204 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753368Ab2C0JRS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2012 05:17:18 -0400
In-Reply-To: <1332840075-5991-1-git-send-email-hayeswang@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Updated firmware with stability fixes.
1. rtl_nic/rtl8168f-1.fw
   Version: 0.0.4
1. rtl_nic/rtl8168f-2.fw
   Version: 0.0.4

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 WHENCE                |    4 ++--
 rtl_nic/rtl8168f-1.fw |  Bin 3136 -> 3136 bytes
 rtl_nic/rtl8168f-2.fw |  Bin 992 -> 1232 bytes
 3 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/WHENCE b/WHENCE
index 8901137..1235477 100644
--- a/WHENCE
+++ b/WHENCE
@@ -1705,10 +1705,10 @@ File: rtl_nic/rtl8168e-3.fw
 Version: 0.0.4
 
 File: rtl_nic/rtl8168f-1.fw
-Version: 0.0.3
+Version: 0.0.4
 
 File: rtl_nic/rtl8168f-2.fw
-Version: 0.0.3
+Version: 0.0.4
 
 File: rtl_nic/rtl8411-1.fw
 Version: 0.0.1
diff --git a/rtl_nic/rtl8168f-1.fw b/rtl_nic/rtl8168f-1.fw
index 10b3885281fd2a3d41bb436c238c2cf69736d32f..41822b54ef44c37400db3ddac26d0e6655e1faa7 100644
GIT binary patch
delta 394
zcmYjM&r1SP5Z<@ClO{$UDpT7`ItA+PD%&a%6kURls6Rlu1VVI(PLVWe9SS<VTOoAl
zmP%oDRXTbT=@zK{f(nYDK+2%$$Dx5?=9}-EZ{908OU{@;v9!EksJb!lSK~@R352~$
zD5wnwRqdOkn5O&?1tBBMOzE1YjKwuY)s&E?dR09d)}vZP*f|&^)p2Z(u@U~j79HK2
zfQATINdgubU@uRIC-z&w7e8Q{2r<ovOfqZoNz>z+XaJtO0B@cE&7Qy72Ux!Xyj}%N
z)~Tm#kS;<skOR!Q0qqe$Rsr-C$#8{q#IKWiJ`0$&(Tp(Ue`n%7?WF)+#D7-lPK*4S
zfUn!Y52X%%YMx~q+$wRl#WT|7z!Bj78=ypwPkmdK2$Q8m{SPklU2wAoKLeTd6fU5X
qv3`EnCObU;zb*iJc$cNdTb2oUr*nyCK5DJ8azSn%XUxavY}GHwt9{}C

delta 454
zcmYjOKS)Ah5P#oO4@(6l5<?4X3L$;(Y4UWlAP7{#*1)9%p+68!k#Qw0tsk_sGzCdY
zVN;71E^SF;g_=zTN<$z~(&=mH;J&-x{qBDE@qJ}S*%24WHn&z)IjE+l<fP=4yneSV
z`IMkfmU|@G0(nOigqV<s1{Fn$BomQXa&}{RB`M2NNDjCaDXjRzf$7WmF=Ijg#@21t
z13*;-tY!d93~-32#Vbn<@M8)vON5x=9^Dwb=kvPvR7(MLy#luMfTI*&DDKn&>rHY}
zP<wd;FdqVRdI3XuQnqNy+Y{O*k@`;e08ItL=YWOY5&&#cZJ+X=NuDz}`Hg;&?ebv*
zXIXw`cv{K<o_qot=#IUv!Zl$NVaofsLRbeVkn6tzzdC^Fw#Ky{0dEfh+ceuf()bqf
zcT^JvKwGf^Rwj)AW>i2{r7BIDt$-IcKntmrDBAzO6iwOrxUmM>9^N(1@#w%as}wzh
QGmN?Tn(4vZ|CPVv7v6f1`2YX_

diff --git a/rtl_nic/rtl8168f-2.fw b/rtl_nic/rtl8168f-2.fw
index c468b8439d7fa5cc926ddc45c2f317c8a2cef384..c3424929bde4dd8caa6f45397ae50212445ba193 100644
GIT binary patch
delta 391
zcmYLEze_@K5P#pNeM+PzCrhxGwE2ARtGu3$L0d>P2H{piP14X{_;HA$aB?UJoElY#
z{s7m;T-pTtMVkaJ1_j+qp@ZW-cb~h@-3?|RBSk~3e01o$p1+sYCC7H`T++#A^jgN%
z0V%d6o=}F-H?}uDt)2Cfc3kabwVQOkLe48>wNbxKN!MKwDnb)955V`vuBue8!BHMm
zJ+Rgl;%1VM!{FrrY}dh9Qt%Ko1Ybz)cn55Tq&EV7&wzh|=U`uh;cxJ3Jeh6P!1(Gv
zjxA5|DYy`5idMBH$=u46I1|wn=yzmLt{gsrOK%e8n1sX^i4_?dyo#SlUx1(GNO@q<
z2J>yOHxG6d_+UvMd^!R@WpPwA{TA2>Y5>#1TPC73%iu>`KKW@3m5o}!@84UdrBt)A
H5xV*X4)%PE

delta 150
zcmcb>`GDPz0SJmpax4tZEYft1;tli+^o$h@4fKu7^bHL`l0Xmu#1DWtgdxbs%*e>V
zDL%;2H{LlvB{kmA(7@8rM8U|w%E-jZ(0rpG8zUzp6I%mQ8Cyg4<XFZUQ8~7T&z5Wr
nj2GD&8utSw6hZvSkC^m;Y#@5OS&UhUkx^x`CChXcpdAbV|1~3f

-- 
1.7.7.6
