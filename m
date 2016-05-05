From: John Crispin <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>
Subject: [PATCH 3/3] net-next: lantiq: change my email address
Date: Thu,  5 May 2016 11:28:46 +0200
Message-ID: <1462440526-52203-3-git-send-email-john@phrozen.org>
References: <1462440526-52203-1-git-send-email-john@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, John Crispin <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>,
 linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, nbd-Vt+b4OUoWG0@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1462440526-52203-1-git-send-email-john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-mediatek/>
List-Post: <mailto:linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-mediatek" <linux-mediatek-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

The old address is no longer valid. Use the new one instead.

Signed-off-by: John Crispin <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>
---
 drivers/net/ethernet/lantiq_etop.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/lantiq_etop.c b/drivers/net/ethernet/lantiq_etop.c
index dc82b1b..fdd76b2 100644
--- a/drivers/net/ethernet/lantiq_etop.c
+++ b/drivers/net/ethernet/lantiq_etop.c
@@ -11,7 +11,7 @@
  *   You should have received a copy of the GNU General Public License
  *   along with this program; if not, see <http://www.gnu.org/licenses/>.
  *
- *   Copyright (C) 2011 John Crispin <blogic-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
+ *   Copyright (C) 2011 John Crispin <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>
  */
 
 #include <linux/kernel.h>
@@ -791,6 +791,6 @@ exit_ltq_etop(void)
 module_init(init_ltq_etop);
 module_exit(exit_ltq_etop);
 
-MODULE_AUTHOR("John Crispin <blogic-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>");
+MODULE_AUTHOR("John Crispin <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>");
 MODULE_DESCRIPTION("Lantiq SoC ETOP");
 MODULE_LICENSE("GPL");
-- 
1.7.10.4
