From: Andrea Gelmini <andrea.gelmini@gelma.net>
Subject: [PATCH 188/199] drivers/atm/uPD98401.h: Checkpatch cleanup
Date: Sun, 23 May 2010 22:06:04 +0200
Message-ID: <1274645175-27335-5-git-send-email-andrea.gelmini@gelma.net>
References: <1274645175-27335-1-git-send-email-andrea.gelmini@gelma.net>
Cc: Chas Williams <chas@cmf.nrl.navy.mil>,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
To: andrea.gelmini@gelma.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:7443 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754790Ab0EWUGe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 May 2010 16:06:34 -0400
Received: by fg-out-1718.google.com with SMTP id 22so1028593fge.1
        for <netdev@vger.kernel.org>; Sun, 23 May 2010 13:06:33 -0700 (PDT)
In-Reply-To: <1274645175-27335-1-git-send-email-andrea.gelmini@gelma.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

drivers/atm/uPD98401.h:2: ERROR: trailing whitespace
drivers/atm/uPD98401.h:4: ERROR: trailing whitespace

Signed-off-by: Andrea Gelmini <andrea.gelmini@gelma.net>
---
 drivers/atm/uPD98401.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/atm/uPD98401.h b/drivers/atm/uPD98401.h
index 0ab3650..4e6a3e0 100644
--- a/drivers/atm/uPD98401.h
+++ b/drivers/atm/uPD98401.h
@@ -1,7 +1,7 @@
 /* drivers/atm/uPD98401.h - NEC uPD98401 (SAR) declarations */
- 
+
 /* Written 1995 by Werner Almesberger, EPFL LRC */
- 
+
 
 #ifndef DRIVERS_ATM_uPD98401_H
 #define DRIVERS_ATM_uPD98401_H
-- 
1.7.1.251.gf80a2

