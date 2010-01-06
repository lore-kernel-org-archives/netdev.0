From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH] pcmci: remove odd bracket
Date: Thu,  7 Jan 2010 02:05:46 +0300
Message-ID: <1262819146-21361-1-git-send-email-a.beregalov@gmail.com>
Cc: netdev@vger.kernel.org, Alexander Beregalov <a.beregalov@gmail.com>
To: linux@dominikbrodowski.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f225.google.com ([209.85.220.225]:61594 "EHLO
	mail-fx0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932332Ab0AFXF7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2010 18:05:59 -0500
Received: by fxm25 with SMTP id 25so11219164fxm.21
        for <netdev@vger.kernel.org>; Wed, 06 Jan 2010 15:05:56 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---
 drivers/net/pcmcia/nmclan_cs.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/pcmcia/nmclan_cs.c b/drivers/net/pcmcia/nmclan_cs.c
index 8a5ae3b..12e3233 100644
--- a/drivers/net/pcmcia/nmclan_cs.c
+++ b/drivers/net/pcmcia/nmclan_cs.c
@@ -1402,7 +1402,6 @@ static void BuildLAF(int *ladrf, int *adr)
   for (i = 0; i < 8; i++)
     printk(KERN_CONT " %02X", ladrf[i]);
   printk(KERN_CONT "\n");
-  }
 #endif
 } /* BuildLAF */
 
-- 
1.6.6

