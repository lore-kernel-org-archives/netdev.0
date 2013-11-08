From: Ben Hutchings <bhutchings@solarflare.com>
Subject: ethtool 3.12 released
Date: Fri, 8 Nov 2013 17:21:26 +0000
Message-ID: <1383931286.3802.28.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Leonardo Potenza <leonardo.potenza@intel.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:41279 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751118Ab3KHRVb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 12:21:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ethtool version 3.12.1 has been released.

This includes a couple of changes that should have gone into 3.12.

Home page: https://ftp.kernel.org/pub/software/network/ethtool/
Download link:
https://ftp.kernel.org/pub/software/network/ethtool/ethtool-3.12.1.tar.xz

Release notes:

	* Fix: Memory corruption when applying external calibration to
	  SFF-8472 module diagnostics (-m option)
	* Feature: Add Intel 82599 and x540 DCB registers to dump
	  (-d option)

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
