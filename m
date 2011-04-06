From: Simon Wood <simon@mungewell.org>
Subject: [PatchV2 : PL25A1 Support - 1/3] whitespace
Date: Tue,  5 Apr 2011 22:16:44 -0600
Message-ID: <1302063406-13077-1-git-send-email-simon@mungewell.org>
References: <1301456667-1648-1-git-send-email-simon@mungewell.org>
Cc: David Brownell <david-b@pacbell.net>,
	Sergei Shtylyov <sshtylyov@mvista.com>,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	Simon Wood <simon@mungewell.org>
To: Greg Kroah-Hartman <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from idcmail-mo1so.shaw.ca ([24.71.223.10]:36712 "EHLO
	idcmail-mo1so.shaw.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750727Ab1DFEQv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 00:16:51 -0400
In-Reply-To: <1301456667-1648-1-git-send-email-simon@mungewell.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Clear up a couple of instances of incorrect whitespace

Signed-off-by: Simon Wood <simon@mungewell.org>
---
 drivers/net/usb/plusb.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/plusb.c b/drivers/net/usb/plusb.c
index 08ad269..30578ea 100644
--- a/drivers/net/usb/plusb.c
+++ b/drivers/net/usb/plusb.c
@@ -134,13 +134,13 @@ static struct usb_driver plusb_driver = {
 
 static int __init plusb_init(void)
 {
- 	return usb_register(&plusb_driver);
+	return usb_register(&plusb_driver);
 }
 module_init(plusb_init);
 
 static void __exit plusb_exit(void)
 {
- 	usb_deregister(&plusb_driver);
+	usb_deregister(&plusb_driver);
 }
 module_exit(plusb_exit);
 
-- 
1.7.0.4

