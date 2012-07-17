From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 0/3] Cleanup for the RPM
Date: Tue, 17 Jul 2012 17:21:08 +0100
Message-ID: <1342542068.2698.7.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:31837 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751944Ab2GQQVM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 12:21:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I haven't tried building RPMs in a while, and I don't know whether
anyone actually uses the bundled spec file.  Anyway, this should freshen
it up a bit.

Ben.

Ben Hutchings (3):
  ethtool.spec: Update summary and description, based on Fedora package
  ethtool.spec: Update URL to the current home page
  ethtool.spec: Do not include ChangeLog or INSTALL

 ethtool.spec.in |   14 ++++++--------
 1 files changed, 6 insertions(+), 8 deletions(-)

-- 
1.7.7.6


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
