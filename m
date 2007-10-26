From: Laszlo Attila Toth <panther@balabit.hu>
Subject: [IFGROUPv5 iproute 1/2] Added IFLA_NET_NS_PID as in kernel v2.6.24-rc1
Date: Fri, 26 Oct 2007 14:30:34 +0200
Message-ID: <11934018351170-git-send-email-panther@balabit.hu>
References: <11934018353825-git-send-email-panther@balabit.hu>
 <11934018354072-git-send-email-panther@balabit.hu>
 <11934018353320-git-send-email-panther@balabit.hu>
 <11934018354079-git-send-email-panther@balabit.hu>
 <11934018352773-git-send-email-panther@balabit.hu>
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	Laszlo Attila Toth <panther@balabit.hu>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:50175 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752175AbXJZMal (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Oct 2007 08:30:41 -0400
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id 2E17EC1196
	for <netdev@vger.kernel.org>; Fri, 26 Oct 2007 14:30:40 +0200 (CEST)
In-Reply-To: <11934018352773-git-send-email-panther@balabit.hu>
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

