From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 7/7] MAINTAINERS: update information for sfc network driver
Date: Wed, 26 Aug 2009 19:19:04 +0100
Message-ID: <1251310744.27345.21.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:60067 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752586AbZHZSTE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2009 14:19:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update the current maintainers and add our email addresses.  Robert
Stonehouse has moved on to other projects.

Move the linux-net-drivers alias to the top since it should always
reach the current maintainers at Solarflare.  Add netdev as the
relevant mailing list.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 MAINTAINERS |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 866253d..058ada4 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4521,9 +4521,10 @@ S:	Supported
 F:	drivers/net/benet/
 
 SFC NETWORK DRIVER
-P:	Steve Hodgson
-P:	Ben Hutchings
-M:	Robert Stonehouse <linux-net-drivers@solarflare.com>
+M:	linux-net-drivers@solarflare.com (alias for current maintainers)
+M:	Steve Hodgson <shodgson@solarflare.com>
+M:	Ben Hutchings <bhutchings@solarflare.com>
+L:	netdev@vger.kernel.org
 S:	Supported
 F:	drivers/net/sfc/
 

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

