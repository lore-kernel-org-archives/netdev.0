From: Ian Morris <ipm@chirality.org.uk>
Subject: [PATCH nf-next 0/7] coding style improvements for netfilter
Date: Sun, 11 Oct 2015 17:32:13 +0100
Message-ID: <1444581140-6255-1-git-send-email-ipm@chirality.org.uk>
Cc: Ian Morris <ipm@chirality.org.uk>
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series of patches improves the coding style of the netfilter-ipv6 
code by addressing some issues detected by checkpatch.

The changes were previously submitted as part of a larger monolithic 
patch but on advice from Pablo, these are being re-sent in smaller, 
more structured batches.

Ian Morris (7):
  netfilter-ipv6: label placement
  netfilter-ipv6: function definition layout
  netfilter-ipv6: code indentation
  netfilter-ipv6: whitespace around operators
  netfilter-ipv6: ternary operator layout
  netfilter-ipv6: improve if statements
  netfilter-ipv6: pointer cast layout

 net/ipv6/netfilter/ip6_tables.c                | 20 ++++++++++----------
 net/ipv6/netfilter/ip6t_SYNPROXY.c             |  2 +-
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |  4 ++--
 net/ipv6/netfilter/nf_conntrack_reasm.c        |  4 ++--
 net/ipv6/netfilter/nf_reject_ipv6.c            |  4 ++--
 net/ipv6/netfilter/nft_chain_route_ipv6.c      |  6 +++---
 6 files changed, 20 insertions(+), 20 deletions(-)

-- 
1.9.1

