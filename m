From: joe@perches.com
Subject: [PATCH] [335/2many] MAINTAINERS - NETLABEL
Date: Sun, 12 Aug 2007 23:32:34 -0700
Message-ID: <46bffb02.uvCHekm8zEjzkgLD%joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: torvalds@linux-foundation.org, paul.moore@hp.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:1233 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966964AbXHMGcq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2007 02:32:46 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add file pattern to MAINTAINER entry

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/MAINTAINERS b/MAINTAINERS
index bc571b8..d05ffcd 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3213,6 +3213,9 @@ M:	paul.moore@hp.com
 W:	http://netlabel.sf.net
 L:	netdev@vger.kernel.org
 S:	Supported
+F:	Documentation/netlabel
+F:	include/net/netlabel.h
+F:	net/netlabel/
 
 NETROM NETWORK LAYER
 P:	Ralf Baechle
