From: pablo@netfilter.org
Subject: [PATCH] netfilter updates for 3.3-rc5
Date: Thu,  1 Mar 2012 12:02:18 +0100
Message-ID: <1330599739-1645-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

Hi David,

This update contains one fix from Florian Westphal for the module
autoload for ebtables.

You can pull this changes from:

git://1984.lsi.us.es/net master

Thanks!

Florian Westphal (1):
  netfilter: bridge: fix module autoload in compat case

 net/bridge/netfilter/ebtables.c |   10 ++--------
 1 files changed, 2 insertions(+), 8 deletions(-)

-- 
1.7.7.3

