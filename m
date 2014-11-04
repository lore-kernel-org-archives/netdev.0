From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 net-next] tcp: spelling s/plugable/pluggable
Date: Tue,  4 Nov 2014 20:25:38 +0100
Message-ID: <1415129138-11901-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/ipv4/tcp_cong.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
index b1c5970..27ead0d 100644
--- a/net/ipv4/tcp_cong.c
+++ b/net/ipv4/tcp_cong.c
@@ -1,5 +1,5 @@
 /*
- * Plugable TCP congestion control support and newReno
+ * Pluggable TCP congestion control support and newReno
  * congestion control.
  * Based on ideas from I/O scheduler support and Web100.
  *
-- 
1.9.3
