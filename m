From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH firmware 1/3] rtl_nic: update firmware for RTL8111E-VL
Date: Tue, 27 Mar 2012 17:21:13 +0800
Message-ID: <1332840075-5991-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <romieu@fr.zoreil.com>, <netdev@vger.kernel.org>,
	<kernel-team@fedoraproject.org>, <linux-kernel@vger.kernel.org>,
	Hayes Wang <hayeswang@realtek.com>
To: <dwmw2@infradead.org>, <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:58205 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757611Ab2C0JRS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2012 05:17:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Updated firmware with stability fixes.
Version: 0.0.4

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 WHENCE                |    2 +-
 rtl_nic/rtl8168e-3.fw |  Bin 3648 -> 3872 bytes
 2 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/WHENCE b/WHENCE
index 392f8c0..8901137 100644
--- a/WHENCE
+++ b/WHENCE
@@ -1702,7 +1702,7 @@ File: rtl_nic/rtl8168e-1.fw
 File: rtl_nic/rtl8168e-2.fw
 
 File: rtl_nic/rtl8168e-3.fw
-Version: 0.0.3
+Version: 0.0.4
 
 File: rtl_nic/rtl8168f-1.fw
 Version: 0.0.3
diff --git a/rtl_nic/rtl8168e-3.fw b/rtl_nic/rtl8168e-3.fw
index 42f9259b84eaf7d59fbe07e18d27828af1b195db..0f888a32676dac18665158da7501452f66a3116a 100644
GIT binary patch
delta 673
zcmYk2PiPZC6vlV*=UEeDjcv8lq-kOzw1~;>cHN`_p*Imch@f~&N?R!YL6Hg~l|EW~
zQHsz(sR|`RKv<epiGl^8dhsB5=t0n1wH|uvsVyE9{04I9z|8N>yzhN)W<Dlssj7i-
zYw}vja!cbU2P<aY%sXjwuwWMpmaUT*Rm@jG!`Lt`oO5l<tlS)#9G$3)-WVIN*rsKh
zw&kQPx9prMJFYQb&*`ET-kf*D^npMZ=WNLb!Hz}A?Vz|L`4HHyB*#HokbD>n3`_0+
z4dgq)N0%jcf$58qkAT|eD5!Papw>xn9=aZI7`g-)T#}sB`zd*bdv!1&IR$EiK2RH^
zTl);C3yy&(;H)O}IZ!t^4qA3|MtCB=G)G(v5U*v4SHTzRbnt5Y@!nHGyr@=!Z)0P`
zU-HEFAq#v}cS9+WZaxk53GrO5gdYyPM3IZ!@-A_-pLlK+x;pW$OWeOq?4Lyoc+}N(
zVo_IHRK_~6PfZ6(#P52De{T_ok}dWUum2+6m?FNnju`VNbVFdiLEK0X$A)0EMx4=|
zz7c1O#51^o{~fo8;tYE7iD&hVyNRo_gkL58_ZfZu!tW39_5)IdwkzU;de-(td{Wl_
z&CDioZHG9Fm+Mj=vKs8di1p+BPF0R1#0hmNk`g1$+Yv{IhVr7RxVQJ;3}UbOBl=#5
J*J>f={RhyU#Do9<

delta 487
zcmYjOODKd<6#nn{9giP1%En`uL=@xy{~5oT*&z!>$<8BV!HN>eLLSF!LwVgusfkh~
zrZke0SW$MAz1PA@60)Ftw=A5x_q@JyzH{!~@SNv1X^?@z-k{|KyUYC%(`Wkp1(sQ1
zI~A6tk`M(NPSCVht+~OmEwd)lT-_L{?d$4}Se6;G0tL1iw*6s$rM7s`84&Sy*N$+n
z%@9|)h_4HY&!E?3mfquD_#YL-%W_FSEbAb?@)1u1=DH;A(~0Nqi1+7-4KK0x6aEu&
z@U!FniTOgT$R(O9-9$GBMSB1kCB!pl07Z#E9paKb;#fVnyNIK*E{R1{UL=Kai)1<e
zViV`0<qN3tpdX+|Kza9wGfEs(_B}=j5$9mE&^|UvM>ouTi;>i3E^Kx)3Fa8^icQ6c
zICF}43ieMcvHneb|3&;h`?t~rabhva{FDxHB*#)##fi*HefB;OZ+swy_Np}Y2H$`W
wTfIswLwbxHQ6$5LN3_LTjDQf^az4%D-unNb8u3>AH0@Z3T{)DotE=Dp1uAiy00000

-- 
1.7.7.6
