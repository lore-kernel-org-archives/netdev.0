From: "John W. Linville" <linville@tuxdriver.com>
Subject: ethtool 4.10 released
Date: Fri, 24 Mar 2017 14:47:48 -0400
Message-ID: <20170324184747.GC16832@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:39481 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965826AbdCXTAO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 15:00:14 -0400
Received: from uucp by smtp.tuxdriver.com with local-rmail (Exim 4.63)
        (envelope-from <linville@tuxdriver.com>)
        id 1crURY-0005CK-BF
        for netdev@vger.kernel.org; Fri, 24 Mar 2017 15:00:12 -0400
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
        by localhost.localdomain (8.15.2/8.14.6) with ESMTP id v2OIlm0O005355
        for <netdev@vger.kernel.org>; Fri, 24 Mar 2017 14:47:48 -0400
Received: (from linville@localhost)
        by localhost.localdomain (8.15.2/8.15.2/Submit) id v2OIlmi1005354
        for netdev@vger.kernel.org; Fri, 24 Mar 2017 14:47:48 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ethtool version 4.10 has been released.

Home page: https://www.kernel.org/pub/software/network/ethtool/
Download link:
https://www.kernel.org/pub/software/network/ethtool/ethtool-4.10.tar.xz

Release notes:

	* Fix: Fix the "advertise" parameter logic.
	* Feature: Implement ETHTOOL_PHY_GTUNABLE/ETHTOOL_PHY_STUNABLE and PHY downshift
	* Feature: add register dump support for fjes driver (-d option)

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
