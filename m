From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 3/5] sctp: Fix a typo in a comment line in sctp_init()
Date: Mon, 22 May 2017 18:39:29 +0200
Message-ID: <9dca8ae4-fd7f-d1de-af7b-87b92bf6411a@users.sourceforge.net>
References: <2845df67-d35d-536a-0a53-b2eb83fe1ba5@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2845df67-d35d-536a-0a53-b2eb83fe1ba5@users.sourceforge.net>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Mon, 22 May 2017 17:43:44 +0200

Add a missing character in this description.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 net/sctp/protocol.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 5e7c8a344770..64756c42cec9 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -1454,7 +1454,7 @@ static __init int sctp_init(void)
 	}
 
 	/* Allocate and initialize the SCTP port hash table.
-	 * Note that order is initalized to start at the max sized
+	 * Note that order is initialized to start at the max sized
 	 * table we want to support.  If we can't get that many pages
 	 * reduce the order and try again
 	 */
-- 
2.13.0
