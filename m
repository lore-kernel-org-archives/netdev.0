From: Andrea Gelmini <andrea.gelmini@gelma.net>
Subject: [PATCH 186/199] drivers/atm/midway.h: Checkpatch cleanup
Date: Sun, 23 May 2010 22:06:02 +0200
Message-ID: <1274645175-27335-3-git-send-email-andrea.gelmini@gelma.net>
References: <1274645175-27335-1-git-send-email-andrea.gelmini@gelma.net>
Cc: Chas Williams <chas@cmf.nrl.navy.mil>,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
To: andrea.gelmini@gelma.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:42071 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754670Ab0EWUGa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 May 2010 16:06:30 -0400
Received: by fxm5 with SMTP id 5so1961403fxm.19
        for <netdev@vger.kernel.org>; Sun, 23 May 2010 13:06:28 -0700 (PDT)
In-Reply-To: <1274645175-27335-1-git-send-email-andrea.gelmini@gelma.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

drivers/atm/midway.h:2: ERROR: trailing whitespace
drivers/atm/midway.h:4: ERROR: trailing whitespace
drivers/atm/midway.h:162: ERROR: space required after that ',' (ctx:VxV)
drivers/atm/midway.h:164: ERROR: space required after that ',' (ctx:VxV)
drivers/atm/midway.h:165: ERROR: space required after that ',' (ctx:VxV)

Signed-off-by: Andrea Gelmini <andrea.gelmini@gelma.net>
---
 drivers/atm/midway.h |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/atm/midway.h b/drivers/atm/midway.h
index 432525a..1d29b1a 100644
--- a/drivers/atm/midway.h
+++ b/drivers/atm/midway.h
@@ -1,7 +1,7 @@
 /* drivers/atm/midway.h - Efficient Networks Midway (SAR) description */
- 
+
 /* Written 1995-1999 by Werner Almesberger, EPFL LRC/ICA */
- 
+
 
 #ifndef DRIVERS_ATM_MIDWAY_H
 #define DRIVERS_ATM_MIDWAY_H
@@ -159,10 +159,10 @@
 #define ENI155_MAGIC	0xa54b872d
 
 struct midway_eprom {
-	unsigned char mac[MAC_LEN],inv_mac[MAC_LEN];
+	unsigned char mac[MAC_LEN], inv_mac[MAC_LEN];
 	unsigned char pad[36];
-	u32 serial,inv_serial;
-	u32 magic,inv_magic;
+	u32 serial, inv_serial;
+	u32 magic, inv_magic;
 };
 
 
-- 
1.7.1.251.gf80a2

