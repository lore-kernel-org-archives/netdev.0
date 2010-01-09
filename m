From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH] net/sunrpc/addr.c: Remove unnecessary semicolons
Date: Fri, 08 Jan 2010 22:36:23 -0800
Message-ID: <1263018983.20926.9.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>

diff --git a/net/sunrpc/addr.c b/net/sunrpc/addr.c
index 6dcdd25..2ef893e 100644
--- a/net/sunrpc/addr.c
+++ b/net/sunrpc/addr.c
@@ -149,7 +149,7 @@ static size_t rpc_pton4(const char *buf, const size_t buflen,
 		return 0;
 
 	sin->sin_family = AF_INET;
-	return sizeof(struct sockaddr_in);;
+	return sizeof(struct sockaddr_in);
 }
 
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)


--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
