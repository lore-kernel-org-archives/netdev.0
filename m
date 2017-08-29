From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH net-next] staging: irda: update MAINTAINERS
Date: Tue, 29 Aug 2017 09:09:29 +0200
Message-ID: <20170829070929.GA15824@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 Joe Perches <joe@perches.com>, linux-kernel@vger.kernel.org
To: davem@davemloft.net, samuel@sortiz.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

Now that the IRDA code has moved under drivers/staging/irda/, update the
MAINTAINERS file with the new location.

Reported-by: Joe Perches <joe@perches.com>
Signed-off-by: Greg Kroah-Hartman gregkh@linuxfoundation.org
---
 MAINTAINERS | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 6fdfe2685eed..ff19b1c3141c 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -7101,9 +7101,7 @@ W:	http://irda.sourceforge.net/
 S:	Maintained
 T:	git git://git.kernel.org/pub/scm/linux/kernel/git/sameo/irda-2.6.git
 F:	Documentation/networking/irda.txt
-F:	drivers/net/irda/
-F:	include/net/irda/
-F:	net/irda/
+F:	drivers/staging/irda/
 
 IRQ DOMAINS (IRQ NUMBER MAPPING LIBRARY)
 M:	Marc Zyngier <marc.zyngier@arm.com>
-- 
2.14.1
