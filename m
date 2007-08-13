From: joe@perches.com
Subject: [PATCH] [338/2many] MAINTAINERS - NETWORK DEVICE DRIVERS
Date: Sun, 12 Aug 2007 23:32:39 -0700
Message-ID: <46bffb07.hBQUdSyYubZ66f1I%joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: torvalds@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jgarzik@pobox.com,
	akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:1256 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967058AbXHMGcz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2007 02:32:55 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add file pattern to MAINTAINER entry

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/MAINTAINERS b/MAINTAINERS
index d9e9813..b67dda3 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3243,6 +3243,7 @@ M:	jgarzik@pobox.com
 L:	netdev@vger.kernel.org
 T:	git kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git
 S:	Maintained
+F:	drivers/net/
 
 NETWORKING [GENERAL]
 P:	Networking Team
