From: Jon Mason <jon.mason@exar.com>
Subject: [PATCH 7/7] vxge: update driver version
Date: Fri, 10 Dec 2010 18:03:02 -0600
Message-ID: <1292025782-16372-7-git-send-email-jon.mason@exar.com>
References: <1292025782-16372-1-git-send-email-jon.mason@exar.com>
Cc: netdev@vger.kernel.org,
	Sivakumar Subramani <sivakumar.subramani@exar.com>,
	Sreenivasa Honnur <sreenivasa.honnur@exar.com>,
	Ram Vepa <ram.vepa@exar.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:59515 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755531Ab0LKADr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 19:03:47 -0500
Received: by mail-gy0-f174.google.com with SMTP id 11so2119446gyb.19
        for <netdev@vger.kernel.org>; Fri, 10 Dec 2010 16:03:47 -0800 (PST)
In-Reply-To: <1292025782-16372-1-git-send-email-jon.mason@exar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update vxge driver version to 2.5.1

Signed-off-by: Jon Mason <jon.mason@exar.com>
Signed-off-by: Ram Vepa <ram.vepa@exar.com>
---
 drivers/net/vxge/vxge-version.h |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/vxge/vxge-version.h b/drivers/net/vxge/vxge-version.h
index 9c93e0a..ad2f99b 100644
--- a/drivers/net/vxge/vxge-version.h
+++ b/drivers/net/vxge/vxge-version.h
@@ -15,9 +15,9 @@
 #define VXGE_VERSION_H
 
 #define VXGE_VERSION_MAJOR	"2"
-#define VXGE_VERSION_MINOR	"0"
-#define VXGE_VERSION_FIX	"11"
-#define VXGE_VERSION_BUILD	"21932"
+#define VXGE_VERSION_MINOR	"5"
+#define VXGE_VERSION_FIX	"1"
+#define VXGE_VERSION_BUILD	"22082"
 #define VXGE_VERSION_FOR	"k"
 
 #define VXGE_FW_VER(maj, min, bld) (((maj) << 16) + ((min) << 8) + (bld))
-- 
1.7.0.4

