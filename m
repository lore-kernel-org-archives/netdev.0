From: joe@perches.com
Subject: [PATCH] [391/2many] MAINTAINERS - PS3 NETWORK SUPPORT
Date: Sun, 12 Aug 2007 23:34:23 -0700
Message-ID: <46bffb6f.CLgzLs+J4a/+58Iy%joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: torvalds@linux-foundation.org, netdev@vger.kernel.org,
	mokuno@sm.sony.co.jp, linux-kernel@vger.kernel.org,
	cbe-oss-dev@ozlabs.org, akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:1578 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S937893AbXHMGej (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2007 02:34:39 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add file pattern to MAINTAINER entry

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/MAINTAINERS b/MAINTAINERS
index 19f2a5f..4fe48a0 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3738,6 +3738,7 @@ M:	mokuno@sm.sony.co.jp
 L:	netdev@vger.kernel.org
 L:	cbe-oss-dev@ozlabs.org
 S:	Supported
+F:	drivers/net/ps3_gelic_net.*
 
 PS3 PLATFORM SUPPORT
 P:	Geoff Levand
