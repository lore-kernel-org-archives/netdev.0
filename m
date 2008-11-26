From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 00/14] Network devices ops (wave 4)
Date: Tue, 25 Nov 2008 17:14:19 -0800
Message-ID: <20081126011419.402319779@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:58782 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752606AbYKZBSq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Nov 2008 20:18:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes the build bug for 8390 library based drivers,
then updates a bunch more drivers.  Build tested all the network drivers
on x86.


