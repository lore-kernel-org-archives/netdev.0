From: Jon Mason <jon.mason@exar.com>
Subject: [PATCH 3/3] vxge: update driver version
Date: Mon, 29 Nov 2010 22:02:47 -0600
Message-ID: <1291089767-18864-3-git-send-email-jon.mason@exar.com>
References: <1291089767-18864-1-git-send-email-jon.mason@exar.com>
Cc: netdev@vger.kernel.org,
	Sivakumar Subramani <sivakumar.subramani@exar.com>,
	Sreenivasa Honnur <sreenivasa.honnur@exar.com>,
	Ram Vepa <ram.vepa@exar.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:52362 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751723Ab0K3EDH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Nov 2010 23:03:07 -0500
Received: by gxk3 with SMTP id 3so104800gxk.19
        for <netdev@vger.kernel.org>; Mon, 29 Nov 2010 20:03:07 -0800 (PST)
In-Reply-To: <1291089767-18864-1-git-send-email-jon.mason@exar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update vxge driver version

Signed-off-by: Jon Mason <jon.mason@exar.com>
---
 drivers/net/vxge/vxge-version.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/vxge/vxge-version.h b/drivers/net/vxge/vxge-version.h
index f05bb2f..9c93e0a 100644
--- a/drivers/net/vxge/vxge-version.h
+++ b/drivers/net/vxge/vxge-version.h
@@ -16,8 +16,8 @@
 
 #define VXGE_VERSION_MAJOR	"2"
 #define VXGE_VERSION_MINOR	"0"
-#define VXGE_VERSION_FIX	"10"
-#define VXGE_VERSION_BUILD	"21808"
+#define VXGE_VERSION_FIX	"11"
+#define VXGE_VERSION_BUILD	"21932"
 #define VXGE_VERSION_FOR	"k"
 
 #define VXGE_FW_VER(maj, min, bld) (((maj) << 16) + ((min) << 8) + (bld))
-- 
1.7.0.4

