From: Jon Mason <jon.mason@exar.com>
Subject: [PATCH 6/6] vxge: Version update
Date: Thu, 15 Jul 2010 13:47:28 -0500
Message-ID: <1279219648-10345-6-git-send-email-jon.mason@exar.com>
Cc: netdev@vger.kernel.org,
	Sreenivasa Honnur <sreenivasa.honnur@exar.com>,
	Ramkrishna Vepa <ramkrishna.vepa@exar.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:56046 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934126Ab0GOSrr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jul 2010 14:47:47 -0400
Received: by mail-px0-f174.google.com with SMTP id 14so527635pxi.19
        for <netdev@vger.kernel.org>; Thu, 15 Jul 2010 11:47:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Version update

Signed-off-by: Jon Mason <jon.mason@exar.com>
Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@exar.com>
Signed-off-by: Ramkrishna Vepa <ramkrishna.vepa@exar.com>
---
 drivers/net/vxge/vxge-version.h |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/vxge/vxge-version.h b/drivers/net/vxge/vxge-version.h
index 4008e6b..53fefe1 100644
--- a/drivers/net/vxge/vxge-version.h
+++ b/drivers/net/vxge/vxge-version.h
@@ -12,12 +12,11 @@
  * Copyright(c) 2002-2010 Exar Corp.
  ******************************************************************************/
 #ifndef VXGE_VERSION_H
-
 #define VXGE_VERSION_H
 
 #define VXGE_VERSION_MAJOR	"2"
 #define VXGE_VERSION_MINOR	"0"
-#define VXGE_VERSION_FIX	"8"
-#define VXGE_VERSION_BUILD	"20182"
+#define VXGE_VERSION_FIX	"9"
+#define VXGE_VERSION_BUILD	"20840"
 #define VXGE_VERSION_FOR	"k"
 #endif
-- 
1.7.0.4

