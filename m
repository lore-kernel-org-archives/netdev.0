From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: [PATCH 2/13] [SCTP] Fix minor typo
Date: Tue, 17 Oct 2006 02:56:55 +0300
Message-ID: <45341C47.7050709@tcs.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: lksctp-developers@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from neon.tcs.hut.fi ([130.233.215.20]:51985 "EHLO neon.tcs.hut.fi")
	by vger.kernel.org with ESMTP id S1422952AbWJPX44 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2006 19:56:56 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Ville Nuorvala <vnuorval@tcs.hut.fi>
---
 net/sctp/socket.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 79c3e07..185d480 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -821,7 +821,7 @@ out:
  * addrs is a pointer to an array of one or more socket addresses. Each
  * address is contained in its appropriate structure (i.e. struct
  * sockaddr_in or struct sockaddr_in6) the family of the address type
- * must be used to distengish the address length (note that this
+ * must be used to distinguish the address length (note that this
  * representation is termed a "packed array" of addresses). The caller
  * specifies the number of addresses in the array with addrcnt.
  *
-- 
1.4.2.3
