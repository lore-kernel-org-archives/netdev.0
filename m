From: Zhu Yanjun <yanjun.zhu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: [PATCHv3 0/4] rds: ib: trivial patches
Date: Mon, 13 Mar 2017 01:43:44 -0400
Message-ID: <1489383828-7699-1-git-send-email-yanjun.zhu@oracle.com>
To: santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org,
        leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

v2 -> v3
remove err from messages.

Zhu Yanjun (4):
  rds: ib: drop unnecessary rdma_reject
  rds: ib: remove redundant ib_dealloc_fmr
  rds: ib: add the static type to the function
  rds: ib: unmap the scatter/gather list when error

 net/rds/ib_cm.c  |  5 ++---
 net/rds/ib_fmr.c | 38 ++++++++++++++++++++++++--------------
 net/rds/ib_mr.h  |  2 --
 3 files changed, 26 insertions(+), 19 deletions(-)

-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
