From: Geoff Levand <geoffrey.levand@am.sony.com>
Subject: [patch] net/ps3: Update maintainer
Date: Tue, 12 May 2009 15:31:30 -0700
Message-ID: <4A09F8C2.5040708@am.sony.com>
References: <49D10994.2010204@am.sony.com> <49F77C32.8020207@am.sony.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org,
	Masakazu Mokuno <mokuno@sm.sony.co.jp>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa4ehsobe003.messaging.microsoft.com ([216.32.181.13]:46823
	"EHLO WA4EHSOBE003.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751612AbZELWbg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2009 18:31:36 -0400
In-Reply-To: <49F77C32.8020207@am.sony.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: net/ps3: Update maintainer

From: Masakazu Mokuno <mokuno@sm.sony.co.jp>

Update the MAINTAINERS entry for PS3 NETWORK SUPPORT.

CC: Masakazu Mokuno <mokuno@sm.sony.co.jp>
Signed-off-by: Geoff Levand <geoffrey.levand@am.sony.com>
---

Hi Jeff,

This is another resend of my patch from March 30th.

I would like to get this in for 2.6.30 so bug reports,
etc. will get routed to the right person.

Please apply. Thanks.

 MAINTAINERS |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4421,8 +4421,8 @@ S:	Maintained
 F:	drivers/ata/sata_promise.*
 
 PS3 NETWORK SUPPORT
-P:	Masakazu Mokuno
-M:	mokuno@sm.sony.co.jp
+P:	Geoff Levand
+M:	geoffrey.levand@am.sony.com
 L:	netdev@vger.kernel.org
 L:	cbe-oss-dev@ozlabs.org
 S:	Supported

