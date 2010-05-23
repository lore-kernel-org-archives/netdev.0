From: Andrea Gelmini <andrea.gelmini@gelma.net>
Subject: [PATCH 187/199] drivers/atm/tonga.h: Checkpatch cleanup
Date: Sun, 23 May 2010 22:06:03 +0200
Message-ID: <1274645175-27335-4-git-send-email-andrea.gelmini@gelma.net>
References: <1274645175-27335-1-git-send-email-andrea.gelmini@gelma.net>
Cc: Chas Williams <chas@cmf.nrl.navy.mil>,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
To: andrea.gelmini@gelma.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:45494 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754750Ab0EWUGc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 May 2010 16:06:32 -0400
Received: by fg-out-1718.google.com with SMTP id d23so1669235fga.1
        for <netdev@vger.kernel.org>; Sun, 23 May 2010 13:06:31 -0700 (PDT)
In-Reply-To: <1274645175-27335-1-git-send-email-andrea.gelmini@gelma.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

drivers/atm/tonga.h:2: ERROR: trailing whitespace
drivers/atm/tonga.h:4: ERROR: trailing whitespace

Signed-off-by: Andrea Gelmini <andrea.gelmini@gelma.net>
---
 drivers/atm/tonga.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/atm/tonga.h b/drivers/atm/tonga.h
index 672da96..66ea795 100644
--- a/drivers/atm/tonga.h
+++ b/drivers/atm/tonga.h
@@ -1,7 +1,7 @@
 /* drivers/atm/tonga.h - Efficient Networks Tonga (PCI bridge) declarations */
- 
+
 /* Written 1995 by Werner Almesberger, EPFL LRC */
- 
+
 
 #ifndef DRIVER_ATM_TONGA_H
 #define DRIVER_ATM_TONGA_H
-- 
1.7.1.251.gf80a2

