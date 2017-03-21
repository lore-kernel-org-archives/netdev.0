From: simran singhal <singhalsimran0@gmail.com>
Subject: [PATCH 0/2] netfilter: Remove unnecessary cast on void pointer
Date: Tue, 21 Mar 2017 17:49:52 +0530
Message-ID: <1490098794-22518-1-git-send-email-singhalsimran0@gmail.com>
Cc: kadlec@blackhole.kfki.hu, davem@davemloft.net,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        outreachy-kernel@googlegroups.com, gregkh@linuxfoundation.org
To: pablo@netfilter.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series remove unnecessary cast on void pointer.

simran singhal (2):
  netfilter: ipset: Remove unnecessary cast on void pointer
  netfilter: Remove unnecessary cast on void pointer

 net/netfilter/ipset/ip_set_bitmap_gen.h |  4 ++--
 net/netfilter/ipset/ip_set_core.c       |  2 +-
 net/netfilter/nf_conntrack_proto.c      |  2 +-
 net/netfilter/nft_set_hash.c            |  2 +-
 net/netfilter/xt_hashlimit.c            | 10 +++++-----
 5 files changed, 10 insertions(+), 10 deletions(-)

-- 
2.7.4
