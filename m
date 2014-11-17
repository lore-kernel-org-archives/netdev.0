From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 net-next] net: fix spelling for synchronized
Date: Mon, 17 Nov 2014 22:04:03 +0100
Message-ID: <1416258243-7685-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/core/dev_addr_lists.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/dev_addr_lists.c b/net/core/dev_addr_lists.c
index b6b2306..c0548d2 100644
--- a/net/core/dev_addr_lists.c
+++ b/net/core/dev_addr_lists.c
@@ -278,8 +278,8 @@ int __hw_addr_sync_dev(struct netdev_hw_addr_list *list,
 EXPORT_SYMBOL(__hw_addr_sync_dev);
 
 /**
- *  __hw_addr_unsync_dev - Remove synchonized addresses from device
- *  @list: address list to remove syncronized addresses from
+ *  __hw_addr_unsync_dev - Remove synchronized addresses from device
+ *  @list: address list to remove synchronized addresses from
  *  @dev:  device to sync
  *  @unsync: function to call if address should be removed
  *
-- 
1.9.3
