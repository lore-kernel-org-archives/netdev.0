From: Xose Vazquez Perez <xose@wanadoo.es>
Subject: [PATCH 2.6-bk 1/1] tg3: add license
Date: Tue, 09 Nov 2004 11:59:58 +0100
Message-ID: <4190A32E.6090200@wanadoo.es>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000508030809010109000007"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, linux-kernel@vger.kernel.org,
        "David S. Miller" <davem@redhat.com>, Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000508030809010109000007
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

hi,

there is no license, yes it's GPL but...

-thanks-

--------------000508030809010109000007
Content-Type: text/plain;
 name="tg3_license.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="tg3_license.diff"

diff -Nuar o/drivers/net/tg3.c n/drivers/net/tg3.c
--- o/drivers/net/tg3.c	2004-11-09 11:49:06.000000000 +0100
+++ n/drivers/net/tg3.c	2004-11-09 11:43:23.000000000 +0100
@@ -9,6 +9,26 @@
  * 	Copyright (C) 2000-2003 Broadcom Corporation.
  */
 
+/*
+ * This file is part of Linux.
+ *
+ * Linux is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License Version 2
+ * as published by the Free Software Foundation.
+ *
+ * Linux is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with Linux; if not, write to:
+ *
+ *   Free Software Foundation Inc.
+ *   59 Temple Place, Suite 330
+ *   Boston MA  02111-1307  USA
+ */
+
 #include <linux/config.h>
 
 #include <linux/module.h>
diff -Nuar o/drivers/net/tg3.h n/drivers/net/tg3.h
--- o/drivers/net/tg3.h	2004-11-09 11:49:06.000000000 +0100
+++ n/drivers/net/tg3.h	2004-11-09 11:46:41.000000000 +0100
@@ -1,4 +1,4 @@
-/* $Id: tg3.h,v 1.37.2.32 2002/03/11 12:18:18 davem Exp $
+/*
  * tg3.h: Definitions for Broadcom Tigon3 ethernet driver.
  *
  * Copyright (C) 2001, 2002, 2003, 2004 David S. Miller (davem@redhat.com)
@@ -6,6 +6,26 @@
  * Copyright (C) 2004 Sun Microsystems Inc.
  */
 
+/*
+ * This file is part of Linux.
+ *
+ * Linux is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License Version 2
+ * as published by the Free Software Foundation.
+ *
+ * Linux is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with Linux; if not, write to:
+ *
+ *   Free Software Foundation Inc.
+ *   59 Temple Place, Suite 330
+ *   Boston MA  02111-1307  USA
+ */
+
 #ifndef _T3_H
 #define _T3_H
 

--------------000508030809010109000007--
