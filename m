From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 00/10] sky2 update for net-next
Date: Fri, 12 Feb 2010 08:57:57 -0800
Message-ID: <20100212165757.767062851@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:49481 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757185Ab0BLRHj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Feb 2010 12:07:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Several little fixes:
   * Change WoL setup to fix http://bugzilla.kernel.org/show_bug.cgi?id=13764
   * Change Jumbo settings for some chips
   * Mike's changes to avoid free and alloc on driver recovery

-- 

