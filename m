From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 2/3] ethtool.spec: Update URL to the current home
 page
Date: Tue, 17 Jul 2012 17:24:01 +0100
Message-ID: <1342542241.2698.10.camel@bwh-desktop.uk.solarflarecom.com>
References: <1342542068.2698.7.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:31918 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751944Ab2GQQYE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 12:24:04 -0400
In-Reply-To: <1342542068.2698.7.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 ethtool.spec.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/ethtool.spec.in b/ethtool.spec.in
index 879555d..863dfd4 100644
--- a/ethtool.spec.in
+++ b/ethtool.spec.in
@@ -6,7 +6,7 @@ Group		: Utilities
 Summary		: Settings tool for Ethernet and other network devices
 
 License		: GPL
-URL		: http://sourceforge.net/projects/gkernel/
+URL		: https://ftp.kernel.org/pub/software/network/ethtool/
 
 Buildroot	: %{_tmppath}/%{name}-%{version}
 Source		: %{name}-%{version}.tar.gz
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
