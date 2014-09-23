From: Wang Sheng-Hui <shhuiw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] net/openvswitch: remove dup comment in vport.h
Date: Tue, 23 Sep 2014 20:02:15 +0800
Message-ID: <1411473735-15184-1-git-send-email-shhuiw@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Wang Sheng-Hui <shhuiw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

Remove the duplicated comment
"/* The following definitions are for users of the vport subsytem: */"
in vport.h

Signed-off-by: Wang Sheng-Hui <shhuiw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 net/openvswitch/vport.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
index 35f89d8..5b43010 100644
--- a/net/openvswitch/vport.h
+++ b/net/openvswitch/vport.h
@@ -35,7 +35,6 @@ struct vport_parms;
 
 /* The following definitions are for users of the vport subsytem: */
 
-/* The following definitions are for users of the vport subsytem: */
 struct vport_net {
 	struct vport __rcu *gre_vport;
 };
-- 
1.8.4.5
