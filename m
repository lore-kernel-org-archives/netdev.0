From: Ian Morris <ipm@chirality.org.uk>
Subject: [PATCH nf-next 0/6] coding style improvements: netfilter-ipv4
Date: Wed, 14 Oct 2015 23:17:02 +0100
Message-ID: <1444861028-21556-1-git-send-email-ipm@chirality.org.uk>
Cc: Ian Morris <ipm@chirality.org.uk>
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series of patches improves the coding style of the netfilter-ipv4 
code by addressing some issues detected by checkpatch.

The changes were previously submitted as part of a larger monolithic 
patch but on advice from Pablo, these are being re-sent in smaller, 
more structured batches.

Ian Morris (6):
  netfilter-ipv4: Line layout whitespace fixes
  netfilter-ipv4: label placement
  netfilter-ipv4: ternary operator layout
  netfilter-ipv4: function definition layout
  netfilter-ipv4: code indentation
  netfilter-ipv4: whitespace around operators

 net/ipv4/netfilter/arp_tables.c        | 12 ++++++------
 net/ipv4/netfilter/ip_tables.c         | 20 ++++++++++----------
 net/ipv4/netfilter/ipt_CLUSTERIP.c     |  8 ++++----
 net/ipv4/netfilter/ipt_ECN.c           |  2 +-
 net/ipv4/netfilter/ipt_SYNPROXY.c      |  2 +-
 net/ipv4/netfilter/ipt_ah.c            |  2 +-
 net/ipv4/netfilter/iptable_security.c  |  2 +-
 net/ipv4/netfilter/nf_nat_pptp.c       |  2 +-
 net/ipv4/netfilter/nf_nat_snmp_basic.c |  4 ++--
 9 files changed, 27 insertions(+), 27 deletions(-)

-- 
1.9.1

