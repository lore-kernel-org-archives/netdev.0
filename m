From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 3/3] rtlwifi: rtl8192cu: Update table.c
Date: Mon, 18 Nov 2013 13:06:57 -0600
Message-ID: <1384801617-22920-4-git-send-email-Larry.Finger@lwfinger.net>
References: <1384801617-22920-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Mark Cave-Ayland <mark.cave-ayland@ilande.co.uk>,
	netdev@vger.kernel.org, Larry Finger <Larry.Finger@lwfinger.net>
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:40194 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752451Ab3KRTHZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 14:07:25 -0500
In-Reply-To: <1384801617-22920-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Cave-Ayland <mark.cave-ayland@ilande.co.uk>

The latest vendor driver has some new values.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Signed-off-by: Mark Cave-Ayland <mark.cave-ayland@ilande.co.uk>
---
 drivers/net/wireless/rtlwifi/rtl8192cu/table.c | 40 +++++++++++++-------------
 1 file changed, 20 insertions(+), 20 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/table.c b/drivers/net/wireless/rtlwifi/rtl8192cu/table.c
index 966be51..7903c15 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/table.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/table.c
@@ -36,7 +36,7 @@ u32 RTL8192CUPHY_REG_2TARRAY[RTL8192CUPHY_REG_2TARRAY_LENGTH] = {
 	0x804, 0x00000003,
 	0x808, 0x0000fc00,
 	0x80c, 0x0000000a,
-	0x810, 0x10005388,
+	0x810, 0x10000330,
 	0x814, 0x020c3d10,
 	0x818, 0x02200385,
 	0x81c, 0x00000000,
@@ -110,22 +110,22 @@ u32 RTL8192CUPHY_REG_2TARRAY[RTL8192CUPHY_REG_2TARRAY_LENGTH] = {
 	0xc44, 0x000100b7,
 	0xc48, 0xec020107,
 	0xc4c, 0x007f037f,
-	0xc50, 0x6954341e,
+	0xc50, 0x69543420,
 	0xc54, 0x43bc0094,
-	0xc58, 0x6954341e,
+	0xc58, 0x69543420,
 	0xc5c, 0x433c0094,
 	0xc60, 0x00000000,
 	0xc64, 0x5116848b,
 	0xc68, 0x47c00bff,
 	0xc6c, 0x00000036,
 	0xc70, 0x2c7f000d,
-	0xc74, 0x0186115b,
+	0xc74, 0x2186115b,
 	0xc78, 0x0000001f,
 	0xc7c, 0x00b99612,
 	0xc80, 0x40000100,
 	0xc84, 0x20f60000,
 	0xc88, 0x40000100,
-	0xc8c, 0x20200000,
+	0xc8c, 0xa0e40000,
 	0xc90, 0x00121820,
 	0xc94, 0x00000000,
 	0xc98, 0x00121820,
@@ -226,7 +226,7 @@ u32 RTL8192CUPHY_REG_1TARRAY[RTL8192CUPHY_REG_1TARRAY_LENGTH] = {
 	0x804, 0x00000001,
 	0x808, 0x0000fc00,
 	0x80c, 0x0000000a,
-	0x810, 0x10005388,
+	0x810, 0x10000330,
 	0x814, 0x020c3d10,
 	0x818, 0x02200385,
 	0x81c, 0x00000000,
@@ -300,9 +300,9 @@ u32 RTL8192CUPHY_REG_1TARRAY[RTL8192CUPHY_REG_1TARRAY_LENGTH] = {
 	0xc44, 0x000100b7,
 	0xc48, 0xec020107,
 	0xc4c, 0x007f037f,
-	0xc50, 0x6954341e,
+	0xc50, 0x69543420,
 	0xc54, 0x43bc0094,
-	0xc58, 0x6954341e,
+	0xc58, 0x69543420,
 	0xc5c, 0x433c0094,
 	0xc60, 0x00000000,
 	0xc64, 0x5116848b,
@@ -340,7 +340,7 @@ u32 RTL8192CUPHY_REG_1TARRAY[RTL8192CUPHY_REG_1TARRAY_LENGTH] = {
 	0xce4, 0x00000000,
 	0xce8, 0x37644302,
 	0xcec, 0x2f97d40c,
-	0xd00, 0x00080740,
+	0xd00, 0x00000740,
 	0xd04, 0x00020401,
 	0xd08, 0x0000907f,
 	0xd0c, 0x20010201,
@@ -633,17 +633,17 @@ u32 RTL8192CURADIOA_2TARRAY[RTL8192CURADIOA_2TARRAYLENGTH] = {
 	0x012, 0x00071000,
 	0x012, 0x000b0000,
 	0x012, 0x000fc000,
-	0x013, 0x000287af,
+	0x013, 0x000287b3,
 	0x013, 0x000244b7,
 	0x013, 0x000204ab,
 	0x013, 0x0001c49f,
 	0x013, 0x00018493,
-	0x013, 0x00014297,
-	0x013, 0x00010295,
-	0x013, 0x0000c298,
-	0x013, 0x0000819c,
-	0x013, 0x000040a8,
-	0x013, 0x0000001c,
+	0x013, 0x0001429b,
+	0x013, 0x00010299,
+	0x013, 0x0000c29c,
+	0x013, 0x000081a0,
+	0x013, 0x000040ac,
+	0x013, 0x00000020,
 	0x014, 0x0001944c,
 	0x014, 0x00059444,
 	0x014, 0x0009944c,
@@ -932,10 +932,10 @@ u32 RTL8192CUMAC_2T_ARRAY[RTL8192CUMAC_2T_ARRAYLENGTH] = {
 	0x608, 0x0000000e,
 	0x609, 0x0000002a,
 	0x652, 0x00000020,
-	0x63c, 0x0000000a,
-	0x63d, 0x0000000e,
-	0x63e, 0x0000000a,
-	0x63f, 0x0000000e,
+	0x63c, 0x00000008,
+	0x63d, 0x00000008,
+	0x63e, 0x0000000c,
+	0x63f, 0x0000000c,
 	0x66e, 0x00000005,
 	0x700, 0x00000021,
 	0x701, 0x00000043,
-- 
1.8.4
