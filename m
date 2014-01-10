From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH] netfilter updates for net-next
Date: Fri, 10 Jan 2014 19:55:57 +0100
Message-ID: <1389380158-8754-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

This batch contains one single patch with the l2tp match
for xtables, from James Chapman.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git master

Thanks!

----------------------------------------------------------------

You can pull these changes from:

The following changes since commit d0eb1f7e66dd53355746cd6a8e7e56c465dc6cde:

  ip_tunnel: fix sparse non static symbol warning (2014-01-09 14:31:47 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git master

for you to fetch changes up to 74f77a6b2b1c98d3f14364dccdd2353b99ecfeda:

  netfilter: introduce l2tp match extension (2014-01-09 21:36:39 +0100)

----------------------------------------------------------------
James Chapman (1):
      netfilter: introduce l2tp match extension

 include/uapi/linux/netfilter/Kbuild    |    1 +
 include/uapi/linux/netfilter/xt_l2tp.h |   27 +++
 net/netfilter/Kconfig                  |   10 +
 net/netfilter/Makefile                 |    1 +
 net/netfilter/xt_l2tp.c                |  354 ++++++++++++++++++++++++++++++++
 5 files changed, 393 insertions(+)
 create mode 100644 include/uapi/linux/netfilter/xt_l2tp.h
 create mode 100644 net/netfilter/xt_l2tp.c

