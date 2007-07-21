From: Jesper Juhl <jesper.juhl@gmail.com>
Subject: [PATCH][33/37] Clean up duplicate includes in
	net/tipc/
Date: Sat, 21 Jul 2007 17:03:58 +0200
Message-ID: <200707211703.59169.jesper.juhl@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>,
	Per Liden <per.liden@ericsson.com>, netdev@vger.kernel.org,
	Jesper Juhl <jesper.juhl@gmail.com>,
	tipc-discussion@lists.sourceforge.net,
	Allan Stephens <allan.stephens@windriver.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David S Miller <davem@davemloft.net>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Sender: tipc-discussion-bounces@lists.sourceforge.net
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Hi,

This patch cleans up duplicate includes in
	net/tipc/


Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
---

diff --git a/net/tipc/port.c b/net/tipc/port.c
index 5d2b9ce..7608815 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -41,7 +41,6 @@
 #include "addr.h"
 #include "link.h"
 #include "node.h"
-#include "port.h"
 #include "name_table.h"
 #include "user_reg.h"
 #include "msg.h"

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
