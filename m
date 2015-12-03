From: Otto Sabart <osabart@redhat.com>
Subject: [BUG] net: performance regression on ixgbe (Intel 82599EB 10-Gigabit
 NIC)
Date: Thu, 3 Dec 2015 17:26:29 +0100
Message-ID: <20151203162627.GA8989@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jirka Hladky <jhladky@redhat.com>,
	Adam Okuliar <aokuliar@redhat.com>,
	Kamil Kolakowski <kkolakow@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44831 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752486AbbLCQ0a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2015 11:26:30 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello netdev,
I probably found a performance regression on ixgbe (Intel 82599EB
10-Gigabit NIC) on v4.4-rc3. I am able to see this problem since
v4.4-rc1.

The bug report you can find here [0].

Can somebody take a look at it?

[0] https://bugzilla.redhat.com/show_bug.cgi?id=1288124


thanks,
Ota
