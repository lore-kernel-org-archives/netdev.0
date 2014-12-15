From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH net-next] fib_trie.txt: fix typo
Date: Mon, 15 Dec 2014 14:58:53 +0800
Message-ID: <548E86AD.3090702@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([59.151.112.132]:19952 "EHLO
	heian.cn.fujitsu.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750792AbaLOG7F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2014 01:59:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Fix the typo, there should be "It".
On the other hand, fix whitespace errors detected by checkpatch.pl

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---
 Documentation/networking/fib_trie.txt | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/Documentation/networking/fib_trie.txt b/Documentation/networking/fib_trie.txt
index 0723db7..fe71938 100644
--- a/Documentation/networking/fib_trie.txt
+++ b/Documentation/networking/fib_trie.txt
@@ -73,8 +73,8 @@ trie_leaf_remove()
 
 trie_rebalance()
 	The key function for the dynamic trie after any change in the trie
-	it is run to optimize and reorganize. Tt will walk the trie upwards 
-	towards the root from a given tnode, doing a resize() at each step 
+	it is run to optimize and reorganize. It will walk the trie upwards
+	towards the root from a given tnode, doing a resize() at each step
 	to implement level compression.
 
 resize()
-- 
1.8.3.1
