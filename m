From: Laszlo Attila Toth <panther@balabit.hu>
Subject: [IFGROUPv4 iproute 1/2] Added IFLA_NET_NS_PID as in kernel v2.6.24-rc1
Date: Thu, 25 Oct 2007 17:03:11 +0200
Message-ID: <11933245933597-git-send-email-panther@balabit.hu>
References: <11933245923082-git-send-email-panther@balabit.hu>
 <11933245922165-git-send-email-panther@balabit.hu>
 <11933245921874-git-send-email-panther@balabit.hu>
 <11933245931626-git-send-email-panther@balabit.hu>
 <11933245933190-git-send-email-panther@balabit.hu>
Cc: Laszlo Attila Toth <panther@balabit.hu>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:51753 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758560AbXJYPDW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Oct 2007 11:03:22 -0400
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id AD83EC1303
	for <netdev@vger.kernel.org>; Thu, 25 Oct 2007 17:03:21 +0200 (CEST)
In-Reply-To: <11933245933190-git-send-email-panther@balabit.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Laszlo Attila Toth <panther@balabit.hu>
---
 include/linux/if_link.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 23b3a8e..c948395 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -78,6 +78,7 @@ enum
 	IFLA_LINKMODE,
 	IFLA_LINKINFO,
 #define IFLA_LINKINFO IFLA_LINKINFO
+	IFLA_NET_NS_PID,
 	__IFLA_MAX
 };
 
-- 
1.5.2.5

