From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [IPV4 4/5] fib_trie: version 0.410
Date: Wed, 23 Jan 2008 14:48:48 -0800
Message-ID: <20080123224858.995658134@linux-foundation.org>
References: <20080123224844.610730277@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:57038 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752031AbYAWXAs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2008 18:00:48 -0500
Content-Disposition: inline; filename=fib-trie-minor.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Increase version to reflect recent changes.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/ipv4/fib_trie.c	2008-01-22 17:50:58.000000000 -0800
+++ b/net/ipv4/fib_trie.c	2008-01-22 17:51:02.000000000 -0800
@@ -50,7 +50,7 @@
  *		Patrick McHardy <kaber@trash.net>
  */
 
-#define VERSION "0.408"
+#define VERSION "0.410"
 
 #include <asm/uaccess.h>
 #include <asm/system.h>

-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>

