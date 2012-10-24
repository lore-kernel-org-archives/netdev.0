From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] MAINTAINERS: Add myself to list of SCTP maintainers
Date: Wed, 24 Oct 2012 15:26:51 -0400
Message-ID: <1351106811-23601-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, linux-sctp@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:54169 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756614Ab2JXT1G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Oct 2012 15:27:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've been messing with the code for a bit, and I figured Vlad could use a hand
as interest in the protocol has picked up over the last year or so.  I've asked
him, and he doesn't seem too upset over the idea :)

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: Vlad Yasevich <vyasevich@gmail.com>
CC: "David S. Miller" <davem@davemloft.net>
CC: linux-sctp@vger.kernel.org
---
 MAINTAINERS | 1 +
 1 file changed, 1 insertion(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 5655bcc..2463a0a 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -6352,6 +6352,7 @@ F:	drivers/scsi/st*
 SCTP PROTOCOL
 M:	Vlad Yasevich <vyasevich@gmail.com>
 M:	Sridhar Samudrala <sri@us.ibm.com>
+M:	Neil Horman <nhorman@tuxdriver.com>
 L:	linux-sctp@vger.kernel.org
 W:	http://lksctp.sourceforge.net
 S:	Maintained
-- 
1.7.11.7
