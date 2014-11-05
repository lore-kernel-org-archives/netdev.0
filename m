From: Ryo Munakata <ryomnktml@gmail.com>
Subject: [PATCH] net/9p: remove a comment about pref member which doesn't exist
Date: Wed,  5 Nov 2014 23:45:58 +0900
Message-ID: <1415198758-18680-1-git-send-email-ryomnktml@gmail.com>
Cc: rminnich@sandia.gov, lucho@ionkov.net, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ryo Munakata <ryomnktml@gmail.com>
To: ericvh@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ryo Munakata <ryomnktml@gmail.com>
---
 include/net/9p/transport.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/include/net/9p/transport.h b/include/net/9p/transport.h
index d9fa68f..2a25dec 100644
--- a/include/net/9p/transport.h
+++ b/include/net/9p/transport.h
@@ -34,7 +34,6 @@
  * @list: used to maintain a list of currently available transports
  * @name: the human-readable name of the transport
  * @maxsize: transport provided maximum packet size
- * @pref: Preferences of this transport
  * @def: set if this transport should be considered the default
  * @create: member function to create a new connection on this transport
  * @close: member function to discard a connection on this transport
-- 
2.1.3
