From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH 15/29] LMC: lanmedia.com is not functional anymore.
Date: Sat, 31 Jul 2010 17:05:38 +0200
Message-ID: <1280588752-9340-15-git-send-email-khc@pm.waw.pl>
References: <m3fwyzzpjf.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:38162 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756540Ab0GaPGU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Jul 2010 11:06:20 -0400
In-Reply-To: <m3fwyzzpjf.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>

Signed-off-by: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>
---
 drivers/net/wan/lmc/ioctl.h |    2 +-
 drivers/net/wan/lmc/main.c  |    3 +--
 drivers/net/wan/lmc/media.c |    2 +-
 drivers/net/wan/lmc/var.h   |    2 +-
 4 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wan/lmc/ioctl.h b/drivers/net/wan/lmc/ioctl.h
index 1b7820f..4914ede 100644
--- a/drivers/net/wan/lmc/ioctl.h
+++ b/drivers/net/wan/lmc/ioctl.h
@@ -2,7 +2,7 @@
 #define _LMC_IOCTL_H_
 /*
  * Copyright (c) 1997-2000 LAN Media Corporation (LMC)
- * All rights reserved.  www.lanmedia.com
+ * All rights reserved.
  *
  * This code is written by:
  * Andrew Stanley-Jones (asj@cban.com)
diff --git a/drivers/net/wan/lmc/main.c b/drivers/net/wan/lmc/main.c
index eb5b2ea..64bd6d5 100644
--- a/drivers/net/wan/lmc/main.c
+++ b/drivers/net/wan/lmc/main.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (c) 1997-2000 LAN Media Corporation (LMC)
- * All rights reserved.  www.lanmedia.com
+ * All rights reserved.
  * Generic HDLC port Copyright (C) 2008 Krzysztof Halasa <khc@pm.waw.p=
l>
  *
  * This code is written by:
@@ -20,7 +20,6 @@
  * Driver for the LanMedia LMC5200, LMC5245, LMC1000, LMC1200 cards.
  *
  * To control link specific options lmcctl is required.
- * It can be obtained from ftp.lanmedia.com.
  *
  * Linux driver notes:
  * Linux uses the device struct lmc_private to pass private informatio=
n
diff --git a/drivers/net/wan/lmc/media.c b/drivers/net/wan/lmc/media.c
index 411138f..5851d19 100644
--- a/drivers/net/wan/lmc/media.c
+++ b/drivers/net/wan/lmc/media.c
@@ -23,7 +23,7 @@
=20
 /*
  * Copyright (c) 1997-2000 LAN Media Corporation (LMC)
- * All rights reserved.  www.lanmedia.com
+ * All rights reserved.
  *
  * This code is written by:
  * Andrew Stanley-Jones (asj@cban.com)
diff --git a/drivers/net/wan/lmc/var.h b/drivers/net/wan/lmc/var.h
index d694731..09b901c 100644
--- a/drivers/net/wan/lmc/var.h
+++ b/drivers/net/wan/lmc/var.h
@@ -3,7 +3,7 @@
=20
 /*
  * Copyright (c) 1997-2000 LAN Media Corporation (LMC)
- * All rights reserved.  www.lanmedia.com
+ * All rights reserved.
  *
  * This code is written by:
  * Andrew Stanley-Jones (asj@cban.com)
--=20
1.7.1.1

