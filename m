From: joe@perches.com
Subject: [PATCH] [353/2many] MAINTAINERS - OLYMPIC NETWORK DRIVER
Date: Sun, 12 Aug 2007 23:33:08 -0700
Message-ID: <46bffb24.IC2iyycpPLNK7J0x%joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: torvalds@linux-foundation.org,
	p2@ace.ulyssis.student.kuleuven.ac.be, netdev@vger.kernel.org,
	mikep@linuxtr.net, linux-tr@linuxtr.net,
	linux-kernel@vger.kernel.org, akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:1335 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967091AbXHMGdV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2007 02:33:21 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add file pattern to MAINTAINER entry

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/MAINTAINERS b/MAINTAINERS
index ab954f1..d2c6850 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3404,6 +3404,8 @@ L:	netdev@vger.kernel.org
 L:	linux-tr@linuxtr.net
 W:	http://www.linuxtr.net
 S:	Maintained
+F:	Documentation/networking/olympic.txt
+F:	drivers/net/tokenring/olympic.*
 
 OMNIKEY CARDMAN 4000 DRIVER
 P:	Harald Welte
