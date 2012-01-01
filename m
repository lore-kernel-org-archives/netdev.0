From: pablo@netfilter.org
Subject: [PATCH] fix for nfacct infrastructure in net-next
Date: Sun,  1 Jan 2012 17:22:24 +0100
Message-ID: <1325434945-21900-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

Hi Dave,

Please, pull the following fix for the nfacct infrastructure already
in your net-next tree.

You can pull it from:

git://1984.lsi.us.es/net-net nf-next

Thanks!

Pablo Neira Ayuso (1):
  netfilter: nfnetlink_acct: fix nfnl_acct_get operation

 net/netfilter/nfnetlink_acct.c |   17 +++++++++++++----
 1 files changed, 13 insertions(+), 4 deletions(-)

-- 
1.7.7.3

