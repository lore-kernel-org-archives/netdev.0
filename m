From: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Subject: [PATCH] Add MODULE_VERSION to the 3c515 driver
Date: Sat, 22 Jan 2005 11:30:37 +0100
Message-ID: <20050122103037.GB6476@bayes.mathematik.tu-chemnitz.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Network Development Mailing List <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Add MODULE_VERSION to the 3c515 driver.

Signed-off-by: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>

--- vanilla-2.6.11-rc1/drivers/net/3c515.c	Wed Jan 12 11:56:16 2005
+++ linux-2.6.11-rc1/drivers/net/3c515.c	Sat Jan 22 11:25:21 2005
@@ -86,6 +86,7 @@
 MODULE_AUTHOR("Donald Becker <becker@scyld.com>");
 MODULE_DESCRIPTION("3Com 3c515 Corkscrew driver");
 MODULE_LICENSE("GPL");
+MODULE_VERSION(DRV_VERSION);
 
 /* "Knobs" for adjusting internal parameters. */
 /* Put out somewhat more debugging messages. (0 - no msg, 1 minimal msgs). */
