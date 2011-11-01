From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 02/21] ethtool.8: Fix initial blank line/page
Date: Tue, 1 Nov 2011 23:13:55 +0000
Message-ID: <1320189235.2758.32.camel@bwh-desktop>
References: <1320186901.2758.30.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:37777 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752553Ab1KAXN7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2011 19:13:59 -0400
In-Reply-To: <1320186901.2758.30.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 8d63f72ccdcb1b19358d753a8f48f08dcd2136f0 included a regression
of the problem fixed in commit 97b5471fc446d60f8772631b9c4e6d824404336d.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 ethtool.8.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/ethtool.8.in b/ethtool.8.in
index f9d3633..286d089 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -75,7 +75,7 @@
 .\"	\(*NC - Network Classifier type values
 .\"
 .ds NC \fBether\fP|\fBip4\fP|\fBtcp4\fP|\fBudp4\fP|\fBsctp4\fP|\fBah4\fP|\fBesp4\fP
-
+..
 .\"
 .\" Start URL.
 .de UR
-- 
1.7.4.4



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
