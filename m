From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] MAINTAINERS: b43 updates
Date: Thu, 24 Jun 2010 16:45:02 -0700
Message-ID: <1277423102.1654.107.camel@Joe-Laptop.home>
References: <cover.1276988387.git.joe@perches.com>
	 <20100624185339.GC2368@tuxdriver.com>
	 <1277408432.1654.80.camel@Joe-Laptop.home>  <4C23B877.4060209@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Stefano Brivio <stefano.brivio@polimi.it>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mb@bu3sch.de, zajec5@gmail.com
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1290 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753789Ab0FXXpG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jun 2010 19:45:06 -0400
In-Reply-To: <4C23B877.4060209@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-06-24 at 14:56 -0500, Larry Finger wrote:
> The primary arbitrator for patches to the subtle parts of b43 is Michael
> Buesch; however, he is no longer an official MAINTAINER. I can ACK some
> things; however, any changes that are associated with my reverse
> engineering of the Broadcom drivers are off limits.

Add Stefano Brivio's name and email address to CREDITS
Removed Stefano Brivio's from B43 MAINTAINERS
Added the b43 development mailing lists
Changed B43 status to "Odd Fixes"

Signed-off-by: Joe Perches <joe@perches.com>
---
 CREDITS     |    4 ++++
 MAINTAINERS |    5 +++--
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/CREDITS b/CREDITS
index 72b4878..30215f0 100644
--- a/CREDITS
+++ b/CREDITS
@@ -495,6 +495,10 @@ S: Kopmansg 2
 S: 411 13  Goteborg
 S: Sweden
 
+N: Stefano Brivio
+E: stefano.brivio@polimi.it
+D: B43 wireless driver
+
 N: Paul Bristow
 E: paul@paulbristow.net
 W: http://paulbristow.net/linux/idefloppy.html
diff --git a/MAINTAINERS b/MAINTAINERS
index 6d119c9..5bc296c 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1225,16 +1225,17 @@ F:	include/net/ax25.h
 F:	net/ax25/
 
 B43 WIRELESS DRIVER
-M:	Stefano Brivio <stefano.brivio@polimi.it>
 L:	linux-wireless@vger.kernel.org
+L:	b43-dev@lists.infradead.org
 W:	http://linuxwireless.org/en/users/Drivers/b43
-S:	Maintained
+S:	Odd Fixes
 F:	drivers/net/wireless/b43/
 
 B43LEGACY WIRELESS DRIVER
 M:	Larry Finger <Larry.Finger@lwfinger.net>
 M:	Stefano Brivio <stefano.brivio@polimi.it>
 L:	linux-wireless@vger.kernel.org
+L:	b43-dev@lists.infradead.org
 W:	http://linuxwireless.org/en/users/Drivers/b43
 S:	Maintained
 F:	drivers/net/wireless/b43legacy/


