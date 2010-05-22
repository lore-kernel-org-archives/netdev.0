From: Huang Weiyi <weiyi.huang@gmail.com>
Subject: [PATCH 01/12] caif: remove unused #include <linux/version.h>
Date: Sun, 23 May 2010 01:11:37 +0800
Message-ID: <1274548297-1624-1-git-send-email-weiyi.huang@gmail.com>
Cc: netdev@vger.kernel.org, Huang Weiyi <weiyi.huang@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f185.google.com ([209.85.222.185]:47586 "EHLO
	mail-pz0-f185.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752677Ab0EVRLn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 May 2010 13:11:43 -0400
Received: by pzk15 with SMTP id 15so1238191pzk.15
        for <netdev@vger.kernel.org>; Sat, 22 May 2010 10:11:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove unused #include <linux/version.h>('s) in
  drivers/net/caif/caif_serial.c

Signed-off-by: Huang Weiyi <weiyi.huang@gmail.com>
---
 drivers/net/caif/caif_serial.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/caif/caif_serial.c b/drivers/net/caif/caif_serial.c
index 09257ca..b259650 100644
--- a/drivers/net/caif/caif_serial.c
+++ b/drivers/net/caif/caif_serial.c
@@ -5,7 +5,6 @@
  */
 
 #include <linux/init.h>
-#include <linux/version.h>
 #include <linux/module.h>
 #include <linux/device.h>
 #include <linux/types.h>
-- 
1.6.1.3

