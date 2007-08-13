From: joe@perches.com
Subject: [PATCH] [342/2many] MAINTAINERS - NETXEN (1/10) GbE SUPPORT
Date: Sun, 12 Aug 2007 23:32:46 -0700
Message-ID: <46bffb0e.H3nQI6dwY+D8gvdP%joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: torvalds@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, amitkale@netxen.com,
	akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:1270 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966511AbXHMGdA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2007 02:33:00 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add file pattern to MAINTAINER entry

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/MAINTAINERS b/MAINTAINERS
index fd59b3d..dbfdb75 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3289,6 +3289,7 @@ M:	amitkale@netxen.com
 L:	netdev@vger.kernel.org
 W:	http://www.netxen.com
 S:	Supported
+F:	drivers/net/netxen/
 
 IPVS
 P:	Wensong Zhang
