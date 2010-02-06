From: Joe Perches <joe@perches.com>
Subject: [PATCH] MAINTAINERS: networking drivers - Add git net-next tree
Date: Sat, 06 Feb 2010 12:43:55 -0800
Message-ID: <1265489035.2063.35.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Maxim Levitsky <maximlevitsky@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1878 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755944Ab0BFUn4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Feb 2010 15:43:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During the rc period, patches that are not bugfixes
should be done using the net-next tree.

Signed-off-by: Joe Perches <joe@perches.com>
---
diff --git a/MAINTAINERS b/MAINTAINERS
index 03f38c1..602022d 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3836,6 +3836,7 @@ NETWORKING DRIVERS
 L:	netdev@vger.kernel.org
 W:	http://www.linuxfoundation.org/en/Net
 T:	git git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.git
+T:	git git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next-2.6.git
 S:	Odd Fixes
 F:	drivers/net/
 F:	include/linux/if_*


