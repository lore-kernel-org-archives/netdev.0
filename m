From: <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 1/1] MAINTAINERS: change netxen_nic maintainers
Date: Thu, 18 Aug 2011 03:44:10 -0700
Message-ID: <1313664250-14639-1-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <ameen.rahman@qlogic.com>,
	Amit Kumar Salecha <amit.salecha@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe004.messaging.microsoft.com ([216.32.181.184]:23865
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755541Ab1HRKyO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2011 06:54:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit.salecha@qlogic.com>

I will no longer maintain netxen_nic driver.
Sony Chacko and Rajesh Borundia are taking over.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
Cc: Sony Chacko <sony.chacko@qlogic.com>
Cc: Rajesh Borundia <rajesh.borundia@qlogic.com>
---
 MAINTAINERS |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index d374c6f..79edb1c 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4495,7 +4495,8 @@ F:	include/linux/if_*
 F:	include/linux/*device.h
 
 NETXEN (1/10) GbE SUPPORT
-M:	Amit Kumar Salecha <amit.salecha@qlogic.com>
+M:	Sony Chacko <sony.chacko@qlogic.com>
+M:	Rajesh Borundia <rajesh.borundia@qlogic.com>
 L:	netdev@vger.kernel.org
 W:	http://www.qlogic.com
 S:	Supported
-- 
1.7.3.3


