From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2-next 1/6] include: update linux/netlink.h
Date: Wed, 20 May 2015 16:19:56 +0200
Message-ID: <1432131601-4641-2-git-send-email-nicolas.dichtel@6wind.com>
References: <20150509.221554.38834063932093195.davem@davemloft.net>
 <1432131601-4641-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:44029 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753942AbbETOUJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 10:20:09 -0400
In-Reply-To: <1432131601-4641-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/linux/netlink.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index e0a09df1a687..0c89ddd73f50 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -108,6 +108,7 @@ struct nlmsgerr {
 #define NETLINK_NO_ENOBUFS	5
 #define NETLINK_RX_RING		6
 #define NETLINK_TX_RING		7
+#define NETLINK_LISTEN_ALL_NSID	8
 
 struct nl_pktinfo {
 	__u32	group;
-- 
2.2.2
