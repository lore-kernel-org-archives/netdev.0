From: joe@perches.com
Subject: [PATCH] [445/2many] MAINTAINERS - SONIC NETWORK DRIVER
Date: Sun, 12 Aug 2007 23:36:09 -0700
Message-ID: <46bffbd9.eUTVbA8A6bfRCZGE%joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: tsbogend@alpha.franken.de, torvalds@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:1872 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967226AbXHMGgX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2007 02:36:23 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add file pattern to MAINTAINER entry

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/MAINTAINERS b/MAINTAINERS
index e9e7a00..6175c77 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4233,6 +4233,7 @@ P:	Thomas Bogendoerfer
 M:	tsbogend@alpha.franken.de
 L:	netdev@vger.kernel.org
 S:	Maintained
+F:	drivers/net/sonic.*
 
 SONY VAIO CONTROL DEVICE DRIVER
 P:	Mattia Dongili
