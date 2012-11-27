From: pablo@netfilter.org
Subject: [PATCH] netfilter updates for net (3.7-rc7)
Date: Tue, 27 Nov 2012 02:03:04 +0100
Message-ID: <1353978185-3564-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

Hi David,

This update contains one patch to fix an overflow via the interface
name attribute in the ipset infrastructure, from Florian Westphal.

You can pull this change from:

git://1984.lsi.us.es/nf master

Thanks!

Florian Westphal (1):
  netfilter: ipset: fix netiface set name overflow

 net/netfilter/ipset/ip_set_hash_netiface.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

-- 
1.7.10.4

