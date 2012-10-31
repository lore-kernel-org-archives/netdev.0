From: Masanari Iida <standby24x7@gmail.com>
Subject: [PATCH/Resend] [trivial] net: sctp: Fix typo in net/sctp
Date: Thu,  1 Nov 2012 00:48:19 +0900
Message-ID: <1351698499-15192-1-git-send-email-standby24x7@gmail.com>
Cc: Masanari Iida <standby24x7@gmail.com>
To: trivial@kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Correct spelling typo in net/sctp/socket.c

Signed-off-by: Masanari Iida <standby24x7@gmail.com>
Acked-by: Vlad Yasevich <vyasevich@gmail.com>
---
 net/sctp/socket.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 59d16ea..a60d1f8 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -974,7 +974,7 @@ SCTP_STATIC int sctp_setsockopt_bindx(struct sock* sk,
 	void *addr_buf;
 	struct sctp_af *af;
 
-	SCTP_DEBUG_PRINTK("sctp_setsocktopt_bindx: sk %p addrs %p"
+	SCTP_DEBUG_PRINTK("sctp_setsockopt_bindx: sk %p addrs %p"
 			  " addrs_size %d opt %d\n", sk, addrs, addrs_size, op);
 
 	if (unlikely(addrs_size <= 0))
-- 
1.8.0.rc3.16.g8ead1bf
