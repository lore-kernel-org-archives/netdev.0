From: joe@perches.com
Subject: [PATCH] [350/2many] MAINTAINERS - NETERION (S2IO) Xframe 10GbE
 DRIVER
Date: Sun, 12 Aug 2007 23:33:02 -0700
Message-ID: <46bffb1e.RWqUKBlIRRtufRxJ%joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: torvalds@linux-foundation.org, sreenivasa.honnur@neterion.com,
	sivakumar.subramani@neterion.com, santosh.rastapur@neterion.com,
	ram.vepa@neterion.com, netdev@vger.kernel.org,
	linux-ke
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:1318 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966950AbXHMGdQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2007 02:33:16 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add file pattern to MAINTAINER entry

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/MAINTAINERS b/MAINTAINERS
index 6e78725..9e9775a 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3373,6 +3373,8 @@ M:	sreenivasa.honnur@neterion.com
 L:	netdev@vger.kernel.org
 W:	http://trac.neterion.com/cgi-bin/trac.cgi/wiki/TitleIndex?anonymous
 S:	Supported
+F:	Documentation/networking/s2io.txt
+F:	drivers/net/s2io*
 
 OPENCORES I2C BUS DRIVER
 P:	Peter Korsgaard
