From: "John W. Linville" <linville@tuxdriver.com>
Subject: ethtool 4.8 released
Date: Tue, 4 Oct 2016 14:43:33 -0400
Message-ID: <20161004184333.GF12675@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:47711 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752778AbcJDSpP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Oct 2016 14:45:15 -0400
Received: from uucp by smtp.tuxdriver.com with local-rmail (Exim 4.63)
        (envelope-from <linville@tuxdriver.com>)
        id 1brUiF-0001iH-0W
        for netdev@vger.kernel.org; Tue, 04 Oct 2016 14:45:11 -0400
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
        by localhost.localdomain (8.15.2/8.14.6) with ESMTP id u94IhXoR031647
        for <netdev@vger.kernel.org>; Tue, 4 Oct 2016 14:43:33 -0400
Received: (from linville@localhost)
        by localhost.localdomain (8.15.2/8.15.2/Submit) id u94IhX0O031646
        for netdev@vger.kernel.org; Tue, 4 Oct 2016 14:43:33 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ethtool version 4.8 has been released.

Home page: https://www.kernel.org/pub/software/network/ethtool/
Download link:
https://www.kernel.org/pub/software/network/ethtool/ethtool-4.8.tar.xz

Release notes:

	* Feature: QSFP Plus/QSFP28 Diagnostics Information Support
	* Feature: Enhancing link mode bits to support 25G/50G/100G
	* Feature: add support for 1000BaseX and missing 10G link mode
	* Fixes: address Coverity issues 1363118 - 1363125

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
