From: joe@perches.com
Subject: [PATCH] [343/2many] MAINTAINERS - IPVS
Date: Sun, 12 Aug 2007 23:32:48 -0700
Message-ID: <46bffb10.JY5EkYQg+QBB0ZZx%joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: wensong@linux-vs.org, torvalds@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org, ja@ssi.bg,
	horms@verge.net.au, akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:1317 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967085AbXHMGdQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2007 02:33:16 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add file pattern to MAINTAINER entry

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/MAINTAINERS b/MAINTAINERS
index dbfdb75..a8fb231 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3300,6 +3300,8 @@ P:	Julian Anastasov
 M:	ja@ssi.bg
 L:	netdev@vger.kernel.org
 S:	Maintained
+F:	Documentation/networking/ipvs-sysctl.txt
+F:	net/ipv4/ipvs
 
 NFS CLIENT
 P:	Trond Myklebust
