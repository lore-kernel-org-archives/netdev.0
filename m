From: joe@perches.com
Subject: [PATCH] [455/2many] MAINTAINERS - SKGE, SKY2 10/100/1000 GIGABIT
 ETHERNET DRIVERS
Date: Sun, 12 Aug 2007 23:36:35 -0700
Message-ID: <46bffbf3.rv8NyuKEk/VVKvwd%joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: torvalds@linux-foundation.org, shemminger@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:1942 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967369AbXHMGgs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2007 02:36:48 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add file pattern to MAINTAINER entry

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/MAINTAINERS b/MAINTAINERS
index a40c7ed..cb9f9da 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4348,6 +4348,8 @@ P:	Stephen Hemminger
 M:	shemminger@linux-foundation.org
 L:	netdev@vger.kernel.org
 S:	Maintained
+F:	drivers/net/skge.*
+F:	drivers/net/sky2.*
 
 SOEKRIS NET48XX LED SUPPORT
 P:	Chris Boot
