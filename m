From: Shine Mohamed Jabbar <shinemohamed_j@naturesoft.net>
Subject: [TRIVIAL PATCH]mistake in the comment in include/linux/wireless.h
Date: Mon, 02 Aug 2004 19:11:03 +0530
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1091454063.25300.109.camel@shine.naturesoft.com>
Reply-To: shinemohamed_j@naturesoft.net
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-kVZOS8vuCIva4VAmkT5m"
Cc: jt@hpl.hp.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-kVZOS8vuCIva4VAmkT5m
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

[Resend - forgot to cc to netdev ML]

Hi Dave,

There is a mistake in the comment given 
in the include/linux/wireless.h. The given 
patch will fix it. Please apply if its useful.

Regards,
Shine Mohamed Jabbar

--=-kVZOS8vuCIva4VAmkT5m
Content-Description: 
Content-Disposition: attachment; filename=diff.patch
Content-Type: text/x-patch; charset=UTF-8
Content-Transfer-Encoding: 7bit

--- linux-2.6.8-rc2-bk11/include/linux/wireless.h.orig	2004-08-02 17:39:11.891418904 +0530
+++ linux-2.6.8-rc2-bk11/include/linux/wireless.h	2004-08-02 17:35:56.309151928 +0530
@@ -47,12 +47,12 @@
  *	# include/net/iw_handler.h
  *
  * Note as well that /proc/net/wireless implementation has now moved in :
- *	# include/linux/wireless.c
+ *	# net/core/wireless.c
  *
  * Wireless Events (2002 -> onward) :
  * --------------------------------
  * Events are defined at the end of this file, and implemented in :
- *	# include/linux/wireless.c
+ *	# net/core/wireless.c
  *
  * Other comments :
  * --------------

--=-kVZOS8vuCIva4VAmkT5m--
