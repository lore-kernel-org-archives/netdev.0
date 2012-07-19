From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] bridge: update documentation references
Date: Thu, 19 Jul 2012 10:01:07 -0700
Message-ID: <20120719100107.088e5bec@s6510.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60965 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751189Ab2GSRB3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jul 2012 13:01:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update the references to bridge utilities and web pages
to current locations

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/Documentation/networking/bridge.txt	2012-07-16 12:08:02.743695241 -0700
+++ b/Documentation/networking/bridge.txt	2012-07-19 09:43:47.955910072 -0700
@@ -1,7 +1,14 @@
 In order to use the Ethernet bridging functionality, you'll need the
-userspace tools. These programs and documentation are available
-at http://www.linuxfoundation.org/en/Net:Bridge.  The download page is
-http://prdownloads.sourceforge.net/bridge.
+userspace tools.
+
+Documentation for Linux bridging is on:
+   http://www.linuxfoundation.org/collaborate/workgroups/networking/bridge
+
+The bridge-utilities are maintained at:
+   git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/bridge-utils.git
+
+Additionally, the iproute2 utilities can be used to configure
+bridge devices.
 
 If you still have questions, don't hesitate to post to the mailing list 
 (more info https://lists.linux-foundation.org/mailman/listinfo/bridge).
