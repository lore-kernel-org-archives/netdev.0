From: joe@perches.com
Subject: [PATCH] [340/2many] MAINTAINERS - NETWORKING [IPv4/IPv6]
Date: Sun, 12 Aug 2007 23:32:43 -0700
Message-ID: <46bffb0b.VAaHa7pZZVVq5+mP%joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: yoshfuji@linux-ipv6.org, torvalds@linux-foundation.org,
	pekkas@netcore.fi, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	kaber@coreworks.de, jmorris@name
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:1423 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967030AbXHMGds (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2007 02:33:48 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add file pattern to MAINTAINER entry

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/MAINTAINERS b/MAINTAINERS
index 1ddb242..91cdf28 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3270,6 +3270,9 @@ M:	kaber@coreworks.de
 L:	netdev@vger.kernel.org
 T:	git kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git
 S:	Maintained
+F:	net/ipv4/
+F:	net/ipv6/
+F:	include/net/ip*
 
 NETWORKING [WIRELESS]
 P:	John W. Linville
