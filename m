From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 0/7] Documentation fixes
Date: Wed, 12 Jan 2011 16:21:06 +0000
Message-ID: <1294849266.3946.0.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:53993 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751900Ab1ALQVJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jan 2011 11:21:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some minor fixes to the online help and manual page.

Ben Hutchings (7):
  ethtool: Fix spelling and spacing in online help
  ethtool.8: Update date, version, web site reference
  ethtool.8: Substitute version at configure time
  ethtool.8: Fix obvious spelling errors
  ethtool.8: Generalise references to network devices, not Ethernet
  ethtool.8: Reword synopses for consistency and style
  ethtool.8: Fix capitalisation

 configure.ac              |    2 +-
 ethtool.8 => ethtool.8.in |  104 ++++++++++++++++++++++++++++++--------------
 ethtool.c                 |    4 +-
 3 files changed, 74 insertions(+), 36 deletions(-)
 rename ethtool.8 => ethtool.8.in (84%)

-- 
1.7.3.4


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

