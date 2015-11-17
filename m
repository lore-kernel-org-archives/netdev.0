From: Stephen Hemminger <stephen@networkplumber.org>
Subject: udp: remove duplicate include
Date: Tue, 17 Nov 2015 13:46:48 -0800
Message-ID: <20151117134648.37d385c2@samsung9>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:36551 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754936AbbKQVrC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2015 16:47:02 -0500
Received: by pacdm15 with SMTP id dm15so20869731pac.3
        for <netdev@vger.kernel.org>; Tue, 17 Nov 2015 13:47:01 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/net/ipv4/udp.c	2015-11-17 13:34:11.977265403 -0800
+++ b/net/ipv4/udp.c	2015-11-17 13:34:11.973265332 -0800
@@ -100,7 +100,6 @@
 #include <linux/slab.h>
 #include <net/tcp_states.h>
 #include <linux/skbuff.h>
-#include <linux/netdevice.h>
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 #include <net/net_namespace.h>
