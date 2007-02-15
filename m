From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH 4/6] atl1: remove unused define
Date: Wed, 14 Feb 2007 20:16:00 -0600
Message-ID: <20070215021600.GE9753@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: csnook@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, atl1-devel@lists.sourceforge.net
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from imf19aec.mail.bellsouth.net ([205.152.59.67]:49828 "EHLO
	imf19aec.mail.bellsouth.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S964855AbXBOCQG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Feb 2007 21:16:06 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Snook <csnook@redhat.com>

Remove unused define from atl1_main.c.

Signed-off-by: Chris Snook <csnook@redhat.com>
Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
---

 drivers/net/atl1/atl1_main.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/atl1/atl1_main.c b/drivers/net/atl1/atl1_main.c
index 6655640..abce97e 100644
--- a/drivers/net/atl1/atl1_main.c
+++ b/drivers/net/atl1/atl1_main.c
@@ -82,7 +82,6 @@
 
 #include "atl1.h"
 
-#define RUN_REALTIME 0
 #define DRIVER_VERSION "2.0.6"
 
 char atl1_driver_name[] = "atl1";
