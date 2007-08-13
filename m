From: joe@perches.com
Subject: [PATCH] [255/2many] MAINTAINERS - INTEL IXP2000 ETHERNET DRIVER
Date: Sun, 12 Aug 2007 23:29:51 -0700
Message-ID: <46bffa5f.Ap1G6z9cjrAITLGp%joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: torvalds@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel@wantstofly.org,
	akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:4743 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966550AbXHMGaH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2007 02:30:07 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add file pattern to MAINTAINER entry

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/MAINTAINERS b/MAINTAINERS
index dccbaba..d5e1d3f 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2423,6 +2423,7 @@ P:	Lennert Buytenhek
 M:	kernel@wantstofly.org
 L:	netdev@vger.kernel.org
 S:	Maintained
+F:	drivers/net/ixp2000/
 
 INTEL PRO/100 ETHERNET SUPPORT
 P:	John Ronciak
