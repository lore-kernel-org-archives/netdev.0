From: joe@perches.com
Subject: [PATCH] [374/2many] MAINTAINERS - PCNET32 NETWORK DRIVER
Date: Sun, 12 Aug 2007 23:33:48 -0700
Message-ID: <46bffb4c.nrqicrPs7IJXlgQ0%joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: torvalds@linux-foundation.org, pcnet32@verizon.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:1480 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967075AbXHMGeB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2007 02:34:01 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add file pattern to MAINTAINER entry

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/MAINTAINERS b/MAINTAINERS
index f6b84d2..7f5b7c2 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3599,6 +3599,7 @@ P:	Don Fry
 M:	pcnet32@verizon.net
 L:	netdev@vger.kernel.org
 S:	Maintained
+F:	drivers/net/pcnet32.c
 
 PER-TASK DELAY ACCOUNTING
 P:	Shailabh Nagar
