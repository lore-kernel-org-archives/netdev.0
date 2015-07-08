From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 6/7] MAINTAINER: add bridge netfilter
Date: Wed,  8 Jul 2015 11:48:19 +0200
Message-ID: <1436348900-13130-7-git-send-email-pablo@netfilter.org>
References: <1436348900-13130-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1436348900-13130-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

So scripts/get_maintainer.pl shows the Netfilter mailing lists.

Reported-by: Julien Grall <julien.grall@citrix.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 MAINTAINERS |    1 +
 1 file changed, 1 insertion(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 993d4cf..8183b465 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -6996,6 +6996,7 @@ F:	include/uapi/linux/netfilter/
 F:	net/*/netfilter.c
 F:	net/*/netfilter/
 F:	net/netfilter/
+F:	net/bridge/br_netfilter*.c
 
 NETLABEL
 M:	Paul Moore <paul@paul-moore.com>
-- 
1.7.10.4

