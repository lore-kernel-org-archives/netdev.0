From: Jon Mason <jon.mason@exar.com>
Subject: [PATCH 4/4] vxge: update driver version
Date: Tue, 18 Jan 2011 19:02:22 -0600
Message-ID: <1295398942-4131-4-git-send-email-jon.mason@exar.com>
References: <1295398942-4131-1-git-send-email-jon.mason@exar.com>
Cc: netdev@vger.kernel.org,
	Sivakumar Subramani <sivakumar.subramani@exar.com>,
	Sreenivasa Honnur <sreenivasa.honnur@exar.com>,
	Ram Vepa <ram.vepa@exar.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:53137 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753110Ab1ASBCr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jan 2011 20:02:47 -0500
Received: by mail-qw0-f46.google.com with SMTP id 26so263152qwa.19
        for <netdev@vger.kernel.org>; Tue, 18 Jan 2011 17:02:46 -0800 (PST)
In-Reply-To: <1295398942-4131-1-git-send-email-jon.mason@exar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update vxge driver version to 2.5.2

Signed-off-by: Jon Mason <jon.mason@exar.com>
---
 drivers/net/vxge/vxge-version.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/vxge/vxge-version.h b/drivers/net/vxge/vxge-version.h
index ad2f99b..581e215 100644
--- a/drivers/net/vxge/vxge-version.h
+++ b/drivers/net/vxge/vxge-version.h
@@ -16,8 +16,8 @@
 
 #define VXGE_VERSION_MAJOR	"2"
 #define VXGE_VERSION_MINOR	"5"
-#define VXGE_VERSION_FIX	"1"
-#define VXGE_VERSION_BUILD	"22082"
+#define VXGE_VERSION_FIX	"2"
+#define VXGE_VERSION_BUILD	"22259"
 #define VXGE_VERSION_FOR	"k"
 
 #define VXGE_FW_VER(maj, min, bld) (((maj) << 16) + ((min) << 8) + (bld))
-- 
1.7.0.4

