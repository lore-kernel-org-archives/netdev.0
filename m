From: Marcelo Abreu <skewer@terra.com.br>
Subject: [PATCH][TRIVIAL] dummy.c: remove dead comment
Date: Sat, 23 Aug 2003 18:21:50 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F47DAEE.7050908@terra.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hi,

	This applies to 2.4 and 2.6.

	The line this comment refers to does not exist anymore.


--- linux-2.4.21/drivers/net/dummy.c	2001-09-30 16:26:06.000000000 -0300
+++ linux-2.4.21-/drivers/net/dummy.c	2003-08-23 17:42:02.000000000 -0300
@@ -28,8 +28,6 @@
 			Alan Cox, 30th May 1994
 */
 
-/* To have statistics (just packets sent) define this */
-
 #include <linux/config.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
