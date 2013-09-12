From: Ben Hutchings <bhutchings@solarflare.com>
Subject: ethtool 3.11 released
Date: Thu, 12 Sep 2013 16:58:24 +0100
Message-ID: <1379001504.7901.0.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:57281 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753099Ab3ILP60 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Sep 2013 11:58:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ethtool version 3.11 has been released.

Home page: https://ftp.kernel.org/pub/software/network/ethtool/
Download link:
https://ftp.kernel.org/pub/software/network/ethtool/ethtool-3.11.tar.xz

Release notes:

	* Feature: Update Realtek chip list for register dump to match
	  r8169 driver in Linux 3.11 (-d option)
	* Feature: Add ixgbevf support for register dump (-d option)
	* Feature: Filter ixgbe register dump according to the specific chip
	  (-d option)

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
