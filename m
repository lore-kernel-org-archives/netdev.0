From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 5/8] openvswitch: Fix misspellings in
	comments and docs.
Date: Fri, 14 Jun 2013 15:28:54 -0700
Message-ID: <1371248937-35614-6-git-send-email-jesse@nicira.com>
References: <1371248937-35614-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1371248937-35614-1-git-send-email-jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Andy Hill <hillad-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Flagged with: https://github.com/lyda/misspell-check
Run with: git ls-files | misspellings -f -

Signed-off-by: Andy Hill <hillad-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/vport.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index 7f20f6d..176d449 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -376,7 +376,7 @@ int ovs_vport_send(struct vport *vport, struct sk_buff *skb)
  * @err_type: one of enum vport_err_type types to indicate the error type
  *
  * If using the vport generic stats layer indicate that an error of the given
- * type has occured.
+ * type has occurred.
  */
 void ovs_vport_record_error(struct vport *vport, enum vport_err_type err_type)
 {
-- 
1.8.1.2
