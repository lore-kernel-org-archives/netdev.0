From: "John W. Linville" <linville@tuxdriver.com>
Subject: ethtool 4.13 released
Date: Fri, 27 Oct 2017 14:25:03 -0400
Message-ID: <20171027141813.GB4837@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:36951 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751951AbdJ0SaM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 14:30:12 -0400
Received: from uucp by smtp.tuxdriver.com with local-rmail (Exim 4.63)
        (envelope-from <linville@tuxdriver.com>)
        id 1e89OV-0007WJ-IM
        for netdev@vger.kernel.org; Fri, 27 Oct 2017 14:30:11 -0400
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
        by localhost.localdomain (8.15.2/8.14.6) with ESMTP id v9RIP3Fn017092
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 14:25:03 -0400
Received: (from linville@localhost)
        by localhost.localdomain (8.15.2/8.15.2/Submit) id v9RIP3Vs017091
        for netdev@vger.kernel.org; Fri, 27 Oct 2017 14:25:03 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ethtool version 4.13 has been released.

Home page: https://www.kernel.org/pub/software/network/ethtool/
Download link:
https://www.kernel.org/pub/software/network/ethtool/ethtool-4.13.tar.xz

Release notes:

	* Fix: Do not return error code if no changes were attempted.
	* Fix: Fix formatting of advertise bitmask
	* Feature: Document 56000 advertise link modes
	* Fix: fix the rx vs tx mixup in set channel message
	* Feature: add support for HWTSTAMP_FILTER_NTP_ALL
	* Feature: Add DMA Coalescing support
	* Feature: Remove UDP Fragmentation Offload error prints
	* Feature: stmmac: Add macros for number of registers
	* Feature: stmmac: Add DMA HW Feature Register

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
