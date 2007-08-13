From: joe@perches.com
Subject: [PATCH] [13/2many] MAINTAINERS - 8390 NETWORK DRIVERS
 [WD80x3/SMC-ELITE, SMC-ULTRA, NE2000, 3C503, etc.]
Date: Sun, 12 Aug 2007 23:21:48 -0700
Message-ID: <46bff87c.UK/38AjJM8GnEaeL%joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: torvalds@linux-foundation.org, p_gortmaker@yahoo.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:3470 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965576AbXHMGWb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2007 02:22:31 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add file pattern to MAINTAINER entry

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/MAINTAINERS b/MAINTAINERS
index 2fc85df..f365b2e 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -172,6 +172,8 @@ P:	Paul Gortmaker
 M:	p_gortmaker@yahoo.com
 L:	netdev@vger.kernel.org
 S:	Maintained
+F:	drivers/net/*8390*
+F:	drivers/net/ax88796.c
 
 9P FILE SYSTEM
 P:	Eric Van Hensbergen
