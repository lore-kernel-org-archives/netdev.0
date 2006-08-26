From: Valerie Henson <val_henson@linux.intel.com>
Subject: [patch 01/10] [TULIP] Change tulip maintainer
Date: Fri, 25 Aug 2006 17:02:28 -0700
Message-ID: <20060826000302.077706000@linux.intel.com>
References: <20060826000227.818796000@linux.intel.com>
Cc: Valerie Henson <val_henson@linux.intel.com>,
	Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([143.182.124.22]:60976 "EHLO
	azsmga101.ch.intel.com") by vger.kernel.org with ESMTP
	id S1422938AbWHZADK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Aug 2006 20:03:10 -0400
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Content-Disposition: inline; filename=tulip-change-tulip-maintainer
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Valerie Henson <val_henson@linux.intel.com>
Cc: Jeff Garzik <jeff@garzik.org>

 MAINTAINERS                    |    4 ++--
 drivers/net/tulip/21142.c      |    2 +-
 drivers/net/tulip/eeprom.c     |    2 +-
 drivers/net/tulip/interrupt.c  |    2 +-
 drivers/net/tulip/media.c      |    2 +-
 drivers/net/tulip/pnic.c       |    2 +-
 drivers/net/tulip/pnic2.c      |    2 +-
 drivers/net/tulip/timer.c      |    2 +-
 drivers/net/tulip/tulip_core.c |    2 +-
 9 files changed, 10 insertions(+), 10 deletions(-)

--- linux-2.6.18-rc4-mm1.orig/MAINTAINERS
+++ linux-2.6.18-rc4-mm1/MAINTAINERS
@@ -2956,8 +2956,8 @@ W:	http://www.auk.cx/tms380tr/
 S:	Maintained
 
 TULIP NETWORK DRIVER
-P:	Jeff Garzik
-M:	jgarzik@pobox.com
+P:	Valerie Henson
+M:	val_henson@linux.intel.com
 L:	tulip-users@lists.sourceforge.net
 W:	http://sourceforge.net/projects/tulip/
 S:	Maintained
--- linux-2.6.18-rc4-mm1.orig/drivers/net/tulip/21142.c
+++ linux-2.6.18-rc4-mm1/drivers/net/tulip/21142.c
@@ -1,7 +1,7 @@
 /*
 	drivers/net/tulip/21142.c
 
-	Maintained by Jeff Garzik <jgarzik@pobox.com>
+	Maintained by Valerie Henson <val_henson@linux.intel.com>
 	Copyright 2000,2001  The Linux Kernel Team
 	Written/copyright 1994-2001 by Donald Becker.
 
--- linux-2.6.18-rc4-mm1.orig/drivers/net/tulip/eeprom.c
+++ linux-2.6.18-rc4-mm1/drivers/net/tulip/eeprom.c
@@ -1,7 +1,7 @@
 /*
 	drivers/net/tulip/eeprom.c
 
-	Maintained by Jeff Garzik <jgarzik@pobox.com>
+	Maintained by Valerie Henson <val_henson@linux.intel.com>
 	Copyright 2000,2001  The Linux Kernel Team
 	Written/copyright 1994-2001 by Donald Becker.
 
--- linux-2.6.18-rc4-mm1.orig/drivers/net/tulip/interrupt.c
+++ linux-2.6.18-rc4-mm1/drivers/net/tulip/interrupt.c
@@ -1,7 +1,7 @@
 /*
 	drivers/net/tulip/interrupt.c
 
-	Maintained by Jeff Garzik <jgarzik@pobox.com>
+	Maintained by Valerie Henson <val_henson@linux.intel.com>
 	Copyright 2000,2001  The Linux Kernel Team
 	Written/copyright 1994-2001 by Donald Becker.
 
--- linux-2.6.18-rc4-mm1.orig/drivers/net/tulip/media.c
+++ linux-2.6.18-rc4-mm1/drivers/net/tulip/media.c
@@ -1,7 +1,7 @@
 /*
 	drivers/net/tulip/media.c
 
-	Maintained by Jeff Garzik <jgarzik@pobox.com>
+	Maintained by Valerie Henson <val_henson@linux.intel.com>
 	Copyright 2000,2001  The Linux Kernel Team
 	Written/copyright 1994-2001 by Donald Becker.
 
--- linux-2.6.18-rc4-mm1.orig/drivers/net/tulip/pnic.c
+++ linux-2.6.18-rc4-mm1/drivers/net/tulip/pnic.c
@@ -1,7 +1,7 @@
 /*
 	drivers/net/tulip/pnic.c
 
-	Maintained by Jeff Garzik <jgarzik@pobox.com>
+	Maintained by Valerie Henson <val_henson@linux.intel.com>
 	Copyright 2000,2001  The Linux Kernel Team
 	Written/copyright 1994-2001 by Donald Becker.
 
--- linux-2.6.18-rc4-mm1.orig/drivers/net/tulip/pnic2.c
+++ linux-2.6.18-rc4-mm1/drivers/net/tulip/pnic2.c
@@ -1,7 +1,7 @@
 /*
 	drivers/net/tulip/pnic2.c
 
-	Maintained by Jeff Garzik <jgarzik@pobox.com>
+	Maintained by Valerie Henson <val_henson@linux.intel.com>
 	Copyright 2000,2001  The Linux Kernel Team
 	Written/copyright 1994-2001 by Donald Becker.
         Modified to hep support PNIC_II by Kevin B. Hendricks
--- linux-2.6.18-rc4-mm1.orig/drivers/net/tulip/timer.c
+++ linux-2.6.18-rc4-mm1/drivers/net/tulip/timer.c
@@ -1,7 +1,7 @@
 /*
 	drivers/net/tulip/timer.c
 
-	Maintained by Jeff Garzik <jgarzik@pobox.com>
+	Maintained by Valerie Henson <val_henson@linux.intel.com>
 	Copyright 2000,2001  The Linux Kernel Team
 	Written/copyright 1994-2001 by Donald Becker.
 
--- linux-2.6.18-rc4-mm1.orig/drivers/net/tulip/tulip_core.c
+++ linux-2.6.18-rc4-mm1/drivers/net/tulip/tulip_core.c
@@ -1,7 +1,7 @@
 /* tulip_core.c: A DEC 21x4x-family ethernet driver for Linux. */
 
 /*
-	Maintained by Jeff Garzik <jgarzik@pobox.com>
+	Maintained by Valerie Henson <val_henson@linux.intel.com>
 	Copyright 2000,2001  The Linux Kernel Team
 	Written/copyright 1994-2001 by Donald Becker.
 

--
