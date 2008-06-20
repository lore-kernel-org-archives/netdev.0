From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH] netdevice: Fix typo of dev_unicast_add() comment
Date: Fri, 20 Jun 2008 23:07:54 +0800
Message-ID: <485BC7CA.7060706@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: NETDEV <netdev@vger.kernel.org>, Patrick McHardy <kaber@trash.net>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:50055 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756146AbYFTPLq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jun 2008 11:11:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 net/core/dev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 61beb4d..b32fbd0 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2986,7 +2986,7 @@ EXPORT_SYMBOL(dev_unicast_delete);
 /**
  *	dev_unicast_add		- add a secondary unicast address
  *	@dev: device
- *	@addr: address to delete
+ *	@addr: address to add
  *	@alen: length of @addr
  *
  *	Add a secondary unicast address to the device or increase
-- 
1.5.3.4



