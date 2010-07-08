From: Jon Mason <jon.mason@exar.com>
Subject: [PATCH 6/6 net-next-2.6] vxge: Version update
Date: Thu, 8 Jul 2010 14:24:03 -0500
Message-ID: <20100708192403.GF15167@exar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Sreenivasa Honnur <sreenivasa.honnur@exar.com>,
	Ramkrishna Vepa <ram.vepa@exar.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:61336 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757419Ab0GHTXZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 15:23:25 -0400
Received: by pvc7 with SMTP id 7so448876pvc.19
        for <netdev@vger.kernel.org>; Thu, 08 Jul 2010 12:23:25 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Version update

Signed-off-by: Jon Mason <jon.mason@exar.com>
Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@exar.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@exar.com>
---
 drivers/net/vxge/vxge-version.h |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/vxge/vxge-version.h b/drivers/net/vxge/vxge-version.h
index 4008e6b..7b9047c 100644
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
+#define VXGE_VERSION_BUILD	"20670"
 #define VXGE_VERSION_FOR	"k"
 #endif
