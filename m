From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: mv643xx(15/20): Add James Chapman to copyright statement and author list
Date: Mon, 28 Mar 2005 16:57:16 -0700
Message-ID: <20050328235715.GO29098@xyzzy>
References: <20050328233807.GA28423@xyzzy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ralf Baechle <ralf@linux-mips.org>, Manish Lachwani <mlachwani@mvista.com>,
        Brian Waite <brian@waitefamily.us>,
        "Steven J. Hill" <sjhill@realitydiluted.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        James Chapman <jchapman@katalix.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Netdev <netdev@oss.sgi.com>, Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20050328233807.GA28423@xyzzy>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: James Chapman <jchapman@katalix.com>
Acked-by: Dale Farnsworth <dale@farnsworth.org>

Index: linux-2.5-enet/drivers/net/mv643xx_eth.c
===================================================================
--- linux-2.5-enet.orig/drivers/net/mv643xx_eth.c
+++ linux-2.5-enet/drivers/net/mv643xx_eth.c
@@ -10,11 +10,14 @@
  *
  * Copyright (C) 2003 Ralf Baechle <ralf@linux-mips.org>
  *
+ * Copyright (C) 2004 Steven J. Hill <sjhill1@rockwellcollins.com>
+ *				     <sjhill@realitydiluted.com>
+ *
  * Copyright (C) 2004-2005 MontaVista Software, Inc.
  *			   Dale Farnsworth <dale@farnsworth.org>
  *
- * Copyright (C) 2004 Steven J. Hill <sjhill1@rockwellcollins.com>
- *				     <sjhill@realitydiluted.com>
+ * Copyright (C) 2005 Katalix Systems Ltd
+ *		      James Chapman <jchapman@katalix.com>
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License
@@ -2710,5 +2713,5 @@
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Rabeeh Khoury, Assaf Hoffman, Matthew Dharm, Manish Lachwani"
-	      " and Dale Farnsworth");
+	      ", Dale Farnsworth and James Chapman");
 MODULE_DESCRIPTION("Ethernet driver for Marvell MV643XX");
