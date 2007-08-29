From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 12/12] sky2: 1.18
Date: Wed, 29 Aug 2007 12:58:21 -0700
Message-ID: <20070829195843.285923333@linux-foundation.org>
References: <20070829193922.078561651@linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:41131 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754995AbXH2UB6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2007 16:01:58 -0400
Content-Disposition: inline; filename=sky2-1.18
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since ther is new functionality (timestamping), increase
the version.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/drivers/net/sky2.c	2007-08-29 11:45:00.000000000 -0700
+++ b/drivers/net/sky2.c	2007-08-29 11:46:25.000000000 -0700
@@ -53,7 +53,7 @@
 #include "sky2.h"
 
 #define DRV_NAME		"sky2"
-#define DRV_VERSION		"1.17"
+#define DRV_VERSION		"1.18"
 #define PFX			DRV_NAME " "
 
 /*

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

