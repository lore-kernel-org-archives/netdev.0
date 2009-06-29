From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: [PATCH 3/3] nl802154: add module license and description
Date: Mon, 29 Jun 2009 19:02:15 +0400
Message-ID: <1246287735-2692-4-git-send-email-dbaryshkov@gmail.com>
References: <1246287735-2692-1-git-send-email-dbaryshkov@gmail.com>
 <1246287735-2692-2-git-send-email-dbaryshkov@gmail.com>
 <1246287735-2692-3-git-send-email-dbaryshkov@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	slapin@ossfans.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:36258 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760169AbZF2PCl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jun 2009 11:02:41 -0400
In-Reply-To: <1246287735-2692-3-git-send-email-dbaryshkov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
---
 net/ieee802154/netlink.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/ieee802154/netlink.c b/net/ieee802154/netlink.c
index 332b947..27eda9f 100644
--- a/net/ieee802154/netlink.c
+++ b/net/ieee802154/netlink.c
@@ -524,3 +524,6 @@ static void __exit ieee802154_nl_exit(void)
 }
 module_exit(ieee802154_nl_exit);
 
+MODULE_LICENSE("GPL v2");
+MODULE_DESCRIPTION("ieee 802.15.4 configuration interface");
+
-- 
1.6.3.1

