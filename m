From: Joe Perches <joe@perches.com>
Subject: [PATCH 0/2] netpoll: Trivial updates
Date: Thu, 30 Jun 2011 18:08:56 -0700
Message-ID: <cover.1309482314.git.joe@perches.com>
Cc: WANG Cong <amwang@redhat.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

cc: WANG Cong <amwang@redhat.com>

Joe Perches (2):
  netpoll: Remove unused EXPORT_SYMBOLs of netpoll_poll and netpoll_poll_dev
  netpoll: Remove trivial wrapper function netpoll_poll

 include/linux/netpoll.h |    2 --
 net/core/netpoll.c      |   13 +++----------
 2 files changed, 3 insertions(+), 12 deletions(-)

-- 
1.7.6.rc1
