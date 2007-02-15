From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH 6/6] atl1: bump version number
Date: Wed, 14 Feb 2007 20:18:05 -0600
Message-ID: <20070215021805.GG9753@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: csnook@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, atl1-devel@lists.sourceforge.net
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from imf19aec.mail.bellsouth.net ([205.152.59.67]:28081 "EHLO
	imf19aec.mail.bellsouth.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S964857AbXBOCSJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Feb 2007 21:18:09 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jay Cliburn <jacliburn@bellsouth.net>

Bump the version number.

Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
---

 drivers/net/atl1/atl1_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/atl1/atl1_main.c b/drivers/net/atl1/atl1_main.c
index 09f3375..6567348 100644
--- a/drivers/net/atl1/atl1_main.c
+++ b/drivers/net/atl1/atl1_main.c
@@ -82,7 +82,7 @@
 
 #include "atl1.h"
 
-#define DRIVER_VERSION "2.0.6"
+#define DRIVER_VERSION "2.0.7"
 
 char atl1_driver_name[] = "atl1";
 static const char atl1_driver_string[] = "Attansic L1 Ethernet Network Driver";
