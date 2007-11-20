From: Laszlo Attila Toth <panther@balabit.hu>
Subject: [PATCHv6 iproute 1/2] Added IFLA_NET_NS_PID as in kernel v2.6.24-rc1
Date: Tue, 20 Nov 2007 14:14:29 +0100
Message-ID: <1195564470805-git-send-email-panther@balabit.hu>
References: <11955644701165-git-send-email-panther@balabit.hu>
 <1195564470928-git-send-email-panther@balabit.hu>
 <11955644702451-git-send-email-panther@balabit.hu>
 <11955644701536-git-send-email-panther@balabit.hu>
 <11955644702194-git-send-email-panther@balabit.hu>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Laszlo Attila Toth <panther@balabit.hu>
To: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <11955644702194-git-send-email-panther@balabit.hu>
Sender: netfilter-devel-owner@vger.kernel.org
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

