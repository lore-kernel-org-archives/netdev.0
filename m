From: Leon Romanovsky <leon@kernel.org>
Subject: [PATCH rdma-next V1 12/19] RDMA/netlink: Update copyright
Date: Thu, 22 Jun 2017 16:24:27 +0300
Message-ID: <20170622132434.1327-13-leon@kernel.org>
References: <20170622132434.1327-1-leon@kernel.org>
Cc: linux-rdma@vger.kernel.org,
        Chien Tin Tung <chien.tin.tung@intel.com>,
        Steve Wise <swise@opengridcomputing.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Ariel Almog <ariela@mellanox.com>,
        Linux Netdev <netdev@vger.kernel.org>,
        Leon Romanovsky <leonro@mellanox.com>
To: Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:60800 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751149AbdFVNZn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 22 Jun 2017 09:25:43 -0400
In-Reply-To: <20170622132434.1327-1-leon@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Leon Romanovsky <leonro@mellanox.com>

Add Mellanox to the copyright header.

Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
Reviewed-by: Steve Wise <swise@opengridcomputing.com>
---
 drivers/infiniband/core/netlink.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/infiniband/core/netlink.c b/drivers/infiniband/core/netlink.c
index 103af358ce4e..58b7ec213c59 100644
--- a/drivers/infiniband/core/netlink.c
+++ b/drivers/infiniband/core/netlink.c
@@ -1,4 +1,5 @@
 /*
+ * Copyright (c) 2017 Mellanox Technologies Inc.  All rights reserved.
  * Copyright (c) 2010 Voltaire Inc.  All rights reserved.
  *
  * This software is available to you under a choice of one of two
-- 
2.13.1
