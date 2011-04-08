From: Jon Mason <jdmason@kudzu.us>
Subject: [net-next PATCH 3/3] vxge: update driver version
Date: Fri,  8 Apr 2011 16:11:23 -0500
Message-ID: <1302297083-22665-3-git-send-email-jdmason@kudzu.us>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:53807 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757969Ab1DHVLe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2011 17:11:34 -0400
Received: by gxk21 with SMTP id 21so1582886gxk.19
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2011 14:11:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update vxge driver version to 2.5.3

Signed-off-by: Jon Mason <jdmason@kudzu.us>
---
 drivers/net/vxge/vxge-version.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/vxge/vxge-version.h b/drivers/net/vxge/vxge-version.h
index 581e215..b9efa28 100644
--- a/drivers/net/vxge/vxge-version.h
+++ b/drivers/net/vxge/vxge-version.h
@@ -16,8 +16,8 @@
 
 #define VXGE_VERSION_MAJOR	"2"
 #define VXGE_VERSION_MINOR	"5"
-#define VXGE_VERSION_FIX	"2"
-#define VXGE_VERSION_BUILD	"22259"
+#define VXGE_VERSION_FIX	"3"
+#define VXGE_VERSION_BUILD	"22640"
 #define VXGE_VERSION_FOR	"k"
 
 #define VXGE_FW_VER(maj, min, bld) (((maj) << 16) + ((min) << 8) + (bld))
-- 
1.7.0.4

