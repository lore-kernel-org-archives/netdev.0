From: Huang Weiyi <weiyi.huang@gmail.com>
Subject: [PATCH 03/12] caif: remove unused #include <linux/version.h>
Date: Sun, 23 May 2010 01:11:57 +0800
Message-ID: <1274548317-4044-1-git-send-email-weiyi.huang@gmail.com>
Cc: netdev@vger.kernel.org, Huang Weiyi <weiyi.huang@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:58077 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753819Ab0EVRMD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 May 2010 13:12:03 -0400
Received: by pxi18 with SMTP id 18so883115pxi.19
        for <netdev@vger.kernel.org>; Sat, 22 May 2010 10:12:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove unused #include <linux/version.h>('s) in
  net/caif/caif_dev.c
  net/caif/chnl_net.c

Signed-off-by: Huang Weiyi <weiyi.huang@gmail.com>
---
 net/caif/caif_dev.c |    1 -
 net/caif/chnl_net.c |    1 -
 2 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/net/caif/caif_dev.c b/net/caif/caif_dev.c
index e2b86f1..a5f1559 100644
--- a/net/caif/caif_dev.c
+++ b/net/caif/caif_dev.c
@@ -9,7 +9,6 @@
  *  and Sakari Ailus <sakari.ailus@nokia.com>
  */
 
-#include <linux/version.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/if_arp.h>
diff --git a/net/caif/chnl_net.c b/net/caif/chnl_net.c
index 610966a..49c4a7b 100644
--- a/net/caif/chnl_net.c
+++ b/net/caif/chnl_net.c
@@ -5,7 +5,6 @@
  * License terms: GNU General Public License (GPL) version 2
  */
 
-#include <linux/version.h>
 #include <linux/fs.h>
 #include <linux/init.h>
 #include <linux/module.h>
-- 
1.6.1.3

