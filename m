From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 12/12] vxlan: bump version
Date: Mon, 10 Jun 2013 13:24:37 -0700
Message-ID: <20130610132437.75a07db5@nehalam.linuxnetplumber.net>
References: <20130610200524.721617349@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:49343 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752599Ab3FJUZn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jun 2013 16:25:43 -0400
Received: by mail-pa0-f47.google.com with SMTP id kl14so1471503pab.34
        for <netdev@vger.kernel.org>; Mon, 10 Jun 2013 13:25:42 -0700 (PDT)
In-Reply-To: <20130610200524.721617349@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/drivers/net/vxlan.c	2013-06-10 12:20:04.974030028 -0700
+++ b/drivers/net/vxlan.c	2013-06-10 12:20:05.754021159 -0700
@@ -42,7 +42,7 @@
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
 
-#define VXLAN_VERSION	"0.1"
+#define VXLAN_VERSION	"0.2"
 
 #define PORT_HASH_BITS	8
 #define PORT_HASH_SIZE  (1<<PORT_HASH_BITS)
