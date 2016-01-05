From: Richard Alpe <richard.alpe@ericsson.com>
Subject: [PATCH iproute2 1/2] tipc: fix help text spelling
	error in node.c
Date: Tue, 5 Jan 2016 10:57:39 +0100
Message-ID: <1451987860-17696-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: tipc-discussion@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
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
 tipc/node.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tipc/node.c b/tipc/node.c
index 163fb74..201fe1a 100644
--- a/tipc/node.c
+++ b/tipc/node.c
@@ -245,7 +245,7 @@ static int cmd_node_get(struct nlmsghdr *nlh, const struct cmd *cmd,
 void cmd_node_help(struct cmdl *cmdl)
 {
 	fprintf(stderr,
-		"Usage: %s media COMMAND [ARGS] ...\n\n"
+		"Usage: %s node COMMAND [ARGS] ...\n\n"
 		"COMMANDS\n"
 		" list                  - List remote nodes\n"
 		" get                   - Get local node parameters\n"
-- 
2.1.4


------------------------------------------------------------------------------
