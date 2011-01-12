From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 6/7] ethtool.8: Reword synopses for consistency and
 style
Date: Wed, 12 Jan 2011 16:23:12 +0000
Message-ID: <1294849392.3946.6.camel@bwh-desktop>
References: <1294849266.3946.0.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:54164 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751381Ab1ALQXO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jan 2011 11:23:14 -0500
In-Reply-To: <1294849266.3946.0.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

diff --git a/ethtool.8.in b/ethtool.8.in
index b7ba73e..203d33d 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -87,7 +87,7 @@
 
 .TH ETHTOOL 8 "January 2011" "Ethtool version @VERSION@"
 .SH NAME
-ethtool \- Display or change network driver and hardware settings
+ethtool \- query or control network driver and hardware settings
 .SH SYNOPSIS
 .B ethtool
 .I ethX
@@ -322,8 +322,8 @@ ethtool \- Display or change network driver and hardware settings
 
 .SH DESCRIPTION
 .BI ethtool
-is used for querying and changing settings of a network device driver
-and hardware, particularly for wired Ethernet devices.
+is used to query and control network device driver and hardware
+settings, particularly for wired Ethernet devices.
 
 .I ethX
 is the name of the network device on which ethtool should operate.
-- 
1.7.3.4



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

