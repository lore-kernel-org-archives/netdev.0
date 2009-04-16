From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/2] MAINTAINERS - Add section NETWORKING DRIVERS
Date: Thu, 16 Apr 2009 12:38:45 -0700
Message-ID: <1239910726-20712-1-git-send-email-joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.LABridge.com ([206.117.136.22]:3638 "EHLO
	mail.perches.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752395AbZDPTiu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 15:38:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joe Perches <joe@perches.com>
---
 MAINTAINERS |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index abbedb6..2e80e68 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3963,6 +3963,13 @@ F:	net/wireless/
 F:	include/net/ieee80211*
 F:	include/net/wireless.h
 
+NETWORKING DRIVERS
+L:	netdev@vger.kernel.org
+W:	http://www.linuxfoundation.org/en/Net
+T:	git git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.git
+S:	Odd Fixes
+F:	drivers/net/
+
 NETXEN (1/10) GbE SUPPORT
 P:	Dhananjay Phadke
 M:	dhananjay@netxen.com
-- 
1.6.1

