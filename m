From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 1/8] rxrpc: Whitespace cleanup
Date: Wed, 07 Sep 2016 16:22:33 +0100
Message-ID: <147326175337.26593.7103675691671617188.stgit@warthog.procyon.org.uk>
References: <147326174610.26593.17043098689515647894.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147326174610.26593.17043098689515647894.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove some whitespace.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-internal.h |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index bb342f5fe7e4..ad702f9f8d1f 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -720,7 +720,6 @@ static inline void rxrpc_put_connection(struct rxrpc_connection *conn)
 	}
 }
 
-
 static inline bool rxrpc_queue_conn(struct rxrpc_connection *conn)
 {
 	if (!rxrpc_get_connection_maybe(conn))
@@ -879,7 +878,7 @@ int __init rxrpc_init_security(void);
 void rxrpc_exit_security(void);
 int rxrpc_init_client_conn_security(struct rxrpc_connection *);
 int rxrpc_init_server_conn_security(struct rxrpc_connection *);
- 
+
 /*
  * sendmsg.c
  */
