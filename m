From: Jon Mason <jon.mason@exar.com>
Subject: [PATCH 11/11] vxge: update driver version
Date: Thu,  4 Nov 2010 17:52:02 -0500
Message-ID: <1288911122-28669-11-git-send-email-jon.mason@exar.com>
References: <1288911122-28669-1-git-send-email-jon.mason@exar.com>
Cc: netdev@vger.kernel.org,
	Sivakumar Subramani <sivakumar.subramani@exar.com>,
	Sreenivasa Honnur <sreenivasa.honnur@exar.com>,
	Ram Vepa <ram.vepa@exar.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:50851 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753459Ab0KDWxK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Nov 2010 18:53:10 -0400
Received: by mail-yw0-f46.google.com with SMTP id 21so1848767ywc.19
        for <netdev@vger.kernel.org>; Thu, 04 Nov 2010 15:53:10 -0700 (PDT)
In-Reply-To: <1288911122-28669-1-git-send-email-jon.mason@exar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update vxge driver version

Signed-off-by: Jon Mason <jon.mason@exar.com>
Signed-off-by: Ram Vepa <ram.vepa@exar.com>
---
 drivers/net/vxge/vxge-version.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/vxge/vxge-version.h b/drivers/net/vxge/vxge-version.h
index b4eced1..f05bb2f 100644
--- a/drivers/net/vxge/vxge-version.h
+++ b/drivers/net/vxge/vxge-version.h
@@ -16,8 +16,8 @@
 
 #define VXGE_VERSION_MAJOR	"2"
 #define VXGE_VERSION_MINOR	"0"
-#define VXGE_VERSION_FIX	"9"
-#define VXGE_VERSION_BUILD	"20840"
+#define VXGE_VERSION_FIX	"10"
+#define VXGE_VERSION_BUILD	"21808"
 #define VXGE_VERSION_FOR	"k"
 
 #define VXGE_FW_VER(maj, min, bld) (((maj) << 16) + ((min) << 8) + (bld))
-- 
1.7.0.4

