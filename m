From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 7/7] ethtool: Add my authorship and Solarflare
 copyright notice
Date: Thu, 23 Sep 2010 22:50:12 +0100
Message-ID: <1285278612.7794.34.camel@achroite.uk.solarflarecom.com>
References: <1285278428.7794.27.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:54753 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755167Ab0IWVuP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Sep 2010 17:50:15 -0400
In-Reply-To: <1285278428.7794.27.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 AUTHORS   |    1 +
 ethtool.c |    2 ++
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/AUTHORS b/AUTHORS
index 77500ce..aed04fa 100644
--- a/AUTHORS
+++ b/AUTHORS
@@ -6,3 +6,4 @@ Eli Kupermann <eli.kupermann@intel.com>
 Chris Leech <christopher.leech@intel.com>
 Scott Feldman <scott.feldman@intel.com>
 Andi Kleen
+Ben Hutchings <bhutchings@solarflare.com>
diff --git a/ethtool.c b/ethtool.c
index 31158f8..7612b14 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -14,6 +14,8 @@
  * amd8111e support by Reeja John <reeja.john@amd.com>
  * long arguments by Andi Kleen.
  * SMSC LAN911x support by Steve Glendinning <steve.glendinning@smsc.com>
+ * Various features by Ben Hutchings <bhutchings@solarflare.com>;
+ *	Copyright 2009, 2010 Solarflare Communications
  *
  * TODO:
  *   * no-args => summary of each device (mii-tool style)
-- 
1.7.2.1


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

