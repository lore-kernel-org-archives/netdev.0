From: joe@perches.com
Subject: [PATCH] [381/2many] MAINTAINERS - POWERPC 4xx EMAC DRIVER
Date: Sun, 12 Aug 2007 23:34:03 -0700
Message-ID: <46bffb5b.SDKlqxp2iUQU9mxr%joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: torvalds@linux-foundation.org, netdev@vger.kernel.org,
	linuxppc-embedded@ozlabs.org, linux-kernel@vger.kernel.org,
	ebs@ebshome.net, akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:1592 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965882AbXHMGen (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2007 02:34:43 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add file pattern to MAINTAINER entry

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/MAINTAINERS b/MAINTAINERS
index 0d30368..f526cf5 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3659,6 +3659,7 @@ W:	http://kernel.ebshome.net/emac/
 L:	linuxppc-embedded@ozlabs.org
 L:	netdev@vger.kernel.org
 S:	Maintained
+F:	drivers/net/ibm_emac/
 
 PNP SUPPORT
 P:	Adam Belay
