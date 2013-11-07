From: Ben Hutchings <bhutchings@solarflare.com>
Subject: ethtool 3.12 released
Date: Thu, 7 Nov 2013 19:56:13 +0000
Message-ID: <1383854173.3802.10.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:36839 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752191Ab3KGT4R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 14:56:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ethtool version 3.12 has been released.

Home page: https://ftp.kernel.org/pub/software/network/ethtool/
Download link:
https://ftp.kernel.org/pub/software/network/ethtool/ethtool-3.12.tar.xz

Release notes:

	* Fix: Remove alternate method to check for VLAN tag offload on Linux
	  < 2.6.37 (-k/-K options)
	* Fix: Hide state of VLAN tag offload and LRO if the kernel is too old
	  for us to reliably detect them (-k option)
	* Feature: Add register dump support for Solarflare SFC9100 family
	  (-d option)

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
