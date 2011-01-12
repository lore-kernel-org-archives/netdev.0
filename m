From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 4/7] ethtool.8: Fix obvious spelling errors
Date: Wed, 12 Jan 2011 16:22:53 +0000
Message-ID: <1294849373.3946.4.camel@bwh-desktop>
References: <1294849266.3946.0.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:54118 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752988Ab1ALQW5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jan 2011 11:22:57 -0500
In-Reply-To: <1294849266.3946.0.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

diff --git a/ethtool.8.in b/ethtool.8.in
index 75f63ba..4554ca0 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -491,12 +491,12 @@ Selects device port.
 .TP
 .A2 autoneg on off
 Specifies whether autonegotiation should be enabled. Autonegotiation 
-is enabled by deafult, but in some network devices may have trouble
+is enabled by default, but in some network devices may have trouble
 with it, so you can disable it if really necessary. 
 .TP
 .BI advertise \ N
 Sets the speed and duplex advertised by autonegotiation.  The argument is
-a hexidecimal value using one or a combination of the following values:
+a hexadecimal value using one or a combination of the following values:
 .RS
 .PD 0
 .TP 3
-- 
1.7.3.4



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

