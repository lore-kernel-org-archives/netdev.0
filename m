From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH 2/2] TIPC: Minor change to comment field
	in API
Date: Mon, 5 Apr 2010 21:16:12 -0400
Message-ID: <1270516572-27789-2-git-send-email-jon.maloy@ericsson.com>
References: <../outgoing_patches/>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net, Jon
To: David Miller <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <../outgoing_patches/>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

---
 include/linux/tipc.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/tipc.h b/include/linux/tipc.h
index 9536d8a..ab2e551 100644
--- a/include/linux/tipc.h
+++ b/include/linux/tipc.h
@@ -86,7 +86,7 @@ static inline unsigned int tipc_node(__u32 addr)
  */
 
 #define TIPC_CFG_SRV		0	/* configuration service name type */
-#define TIPC_TOP_SRV		1	/* topology service name type */
+#define TIPC_TOP_SRV		1	/* topology service name type and instance*/
 #define TIPC_RESERVED_TYPES	64	/* lowest user-publishable name type */
 
 /* 
-- 
1.5.4.3


------------------------------------------------------------------------------
Download Intel&#174; Parallel Studio Eval
Try the new software tools for yourself. Speed compiling, find bugs
proactively, and fine-tune applications for parallel performance.
See why Intel Parallel Studio got high marks during beta.
http://p.sf.net/sfu/intel-sw-dev
