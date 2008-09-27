From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH 4/4] atl1: update introductory comments
Date: Sat, 27 Sep 2008 09:17:23 -0500
Message-ID: <1222525043-4648-5-git-send-email-jacliburn@bellsouth.net>
References: <1222525043-4648-1-git-send-email-jacliburn@bellsouth.net>
Cc: csnook@redhat.com, jie.yang@atheros.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Jay Cliburn <jacliburn@bellsouth.net>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost01.isp.att.net ([204.127.217.101]:48401 "EHLO
	fmailhost01.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752546AbYI0OWb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Sep 2008 10:22:31 -0400
In-Reply-To: <1222525043-4648-1-git-send-email-jacliburn@bellsouth.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update the driver's introductory comments.

Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
---
 drivers/net/atlx/atl1.c |   10 +++-------
 1 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index 5f157e0..3cf59a7 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -24,16 +24,12 @@
  * file called COPYING.
  *
  * Contact Information:
- * Xiong Huang <xiong_huang@attansic.com>
- * Attansic Technology Corp. 3F 147, Xianzheng 9th Road, Zhubei,
- * Xinzhu  302, TAIWAN, REPUBLIC OF CHINA
- *
+ * Xiong Huang <xiong.huang@atheros.com>
+ * Jie Yang <jie.yang@atheros.com>
  * Chris Snook <csnook@redhat.com>
  * Jay Cliburn <jcliburn@gmail.com>
  *
- * This version is adapted from the Attansic reference driver for
- * inclusion in the Linux kernel.  It is currently under heavy development.
- * A very incomplete list of things that need to be dealt with:
+ * This version is adapted from the Attansic reference driver.
  *
  * TODO:
  * Add more ethtool functions.
-- 
1.5.5.1

