From: Joe Perches <joe@perches.com>
Subject: [PATCH] MAINTAINERS: Add git net-next-2.6
Date: Wed, 04 Nov 2009 09:34:09 -0800
Message-ID: <1257356049.16511.3.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1230 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932188AbZKDReE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Nov 2009 12:34:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a reference to the the git tree where most
of the forward going network development occurs.

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/MAINTAINERS b/MAINTAINERS
index e1cf731..0350ace 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3655,6 +3655,7 @@ L:	netdev@vger.kernel.org
 W:	http://www.linuxfoundation.org/en/Net
 W:	http://patchwork.ozlabs.org/project/netdev/list/
 T:	git git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.git
+T:	git git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next-2.6.git
 S:	Maintained
 F:	net/
 F:	include/net/


