From: Benjamin LaHaise <ben.lahaise@neterion.com>
Subject: [6/6] vxge: Version update
Date: Tue, 4 Aug 2009 16:22:19 -0400
Message-ID: <20090804202219.GG9924@neterion.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:33064 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932537AbZHDUj6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 16:39:58 -0400
Received: from guinness.s2io.com (localhost [127.0.0.1])
	by barracuda.s2io.com (Spam Firewall) with ESMTP id BDAA42065FF6
	for <netdev@vger.kernel.org>; Tue,  4 Aug 2009 16:22:21 -0400 (EDT)
Received: from guinness.s2io.com (142-46-210.147.tel-ott.com [142.46.210.147]) by barracuda.s2io.com with ESMTP id A7eKzVAWqDxiHnns for <netdev@vger.kernel.org>; Tue, 04 Aug 2009 16:22:21 -0400 (EDT)
Received: from neterion.com ([10.16.18.36])
	by guinness.s2io.com (8.12.6/8.12.6) with ESMTP id n74KMKmd013329
	for <netdev@vger.kernel.org>; Tue, 4 Aug 2009 16:22:20 -0400 (EDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update the driver version number for any bug reports from end users.

Signed-off-by: Benjamin LaHaise <ben.lahaise@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
diff --git a/drivers/net/vxge/vxge-version.h b/drivers/net/vxge/vxge-version.h
index 580c6eb..8fbce75 100644
--- a/drivers/net/vxge/vxge-version.h
+++ b/drivers/net/vxge/vxge-version.h
@@ -17,7 +17,7 @@
 
 #define VXGE_VERSION_MAJOR	"2"
 #define VXGE_VERSION_MINOR	"0"
-#define VXGE_VERSION_FIX	"4"
-#define VXGE_VERSION_BUILD	"17899"
+#define VXGE_VERSION_FIX	"5"
+#define VXGE_VERSION_BUILD	"18053"
 #define VXGE_VERSION_FOR	"k"
 #endif
