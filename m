From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 15/47] cxgb4: remove forgotten unused vlan_group
Date: Wed, 20 Jul 2011 16:54:17 +0200
Message-ID: <1311173689-17419-16-git-send-email-jpirko@redhat.com>
References: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	eric.dumazet@gmail.com, greearb@candelatech.com, mirqus@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26308 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751837Ab1GTOzU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 10:55:20 -0400
In-Reply-To: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/cxgb4/cxgb4.h |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/cxgb4/cxgb4.h b/drivers/net/cxgb4/cxgb4.h
index bc9982a..223a7f7 100644
--- a/drivers/net/cxgb4/cxgb4.h
+++ b/drivers/net/cxgb4/cxgb4.h
@@ -276,7 +276,6 @@ enum {
 };
 
 struct adapter;
-struct vlan_group;
 struct sge_rspq;
 
 struct port_info {
-- 
1.7.6

