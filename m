From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] net/bluetooth/lib.c: remove unneeded #defines
Date: Thu, 29 Sep 2005 00:28:56 +0400
Message-ID: <20050928202856.GA27645@mipter.zuzino.mipt.ru>
Reply-To: bluez-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bluez-devel@lists.sf.net, netdev@vger.kernel.org
Return-path: <bluez-devel-admin@lists.sourceforge.net>
To: Marcel Holtmann <marcel@holtmann.org>,
	Maxim Krasnyansky <maxk@qualcomm.com>
Content-Disposition: inline
Sender: bluez-devel-admin@lists.sourceforge.net
Errors-To: bluez-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/bluez-devel>,
	<mailto:bluez-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:bluez-devel@lists.sourceforge.net>
List-Help: <mailto:bluez-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/bluez-devel>,
	<mailto:bluez-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=bluez-devel>
List-Id: netdev.vger.kernel.org

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/bluetooth/lib.c |    3 ---
 1 file changed, 3 deletions(-)

--- a/net/bluetooth/lib.c
+++ b/net/bluetooth/lib.c
@@ -24,12 +24,9 @@
 
 /* Bluetooth kernel library. */
 
-#include <linux/config.h>
 #include <linux/module.h>
 
 #include <linux/kernel.h>
-#include <linux/stddef.h>
-#include <linux/string.h>
 #include <asm/errno.h>
 
 #include <net/bluetooth/bluetooth.h>



-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
