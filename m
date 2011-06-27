From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH] MAINTAINERS: drop Michael from bfin_mac driver
Date: Mon, 27 Jun 2011 14:24:07 -0400
Message-ID: <1309199047-18843-1-git-send-email-vapier@gentoo.org>
Cc: michael.hennerich@analog.com, linux-kernel@vger.kernel.org
To: uclinux-dist-devel@blackfin.uclinux.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:54370 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753201Ab1F0SYG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jun 2011 14:24:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We want people to just use the list now rather than hitting up people
who are no longer responsible for it.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 MAINTAINERS |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 1cb0d86..d4aa639 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1424,7 +1424,6 @@ S:	Supported
 F:	arch/blackfin/
 
 BLACKFIN EMAC DRIVER
-M:	Michael Hennerich <michael.hennerich@analog.com>
 L:	uclinux-dist-devel@blackfin.uclinux.org
 W:	http://blackfin.uclinux.org
 S:	Supported
-- 
1.7.5.3

