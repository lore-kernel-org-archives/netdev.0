From: "John W. Linville" <linville@tuxdriver.com>
Subject: ethtool 4.11 released
Date: Fri, 2 Jun 2017 13:55:13 -0400
Message-ID: <20170602175513.GB4837@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:43850 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751154AbdFBSAN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2017 14:00:13 -0400
Received: from uucp by smtp.tuxdriver.com with local-rmail (Exim 4.63)
        (envelope-from <linville@tuxdriver.com>)
        id 1dGqrr-00023u-Eb
        for netdev@vger.kernel.org; Fri, 02 Jun 2017 14:00:11 -0400
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
        by localhost.localdomain (8.15.2/8.14.6) with ESMTP id v52HtEgJ023758
        for <netdev@vger.kernel.org>; Fri, 2 Jun 2017 13:55:14 -0400
Received: (from linville@localhost)
        by localhost.localdomain (8.15.2/8.15.2/Submit) id v52HtDNl023757
        for netdev@vger.kernel.org; Fri, 2 Jun 2017 13:55:13 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ethtool version 4.11 has been released.

Home page: https://www.kernel.org/pub/software/network/ethtool/
Download link:
https://www.kernel.org/pub/software/network/ethtool/ethtool-4.11.tar.xz

Release notes:

	* Feature: Support for configurable RSS hash function
	* Feature: support queue and VF fields for rxclass filters
	* Feature: Add support for 2500baseT/5000baseT link modes
	* Fix: Fix SFF 8079 cable technology bit parsing
	* Fix: sync help output for -x/-X with man page

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
