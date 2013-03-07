From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/6] Mellanox Core and Ethernet driver fixes
 2013-03-07
Date: Thu, 07 Mar 2013 15:52:53 -0500 (EST)
Message-ID: <20130307.155253.396429921313642600.davem@davemloft.net>
References: <1362664017-30275-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46012 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752571Ab3CGUwz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 15:52:55 -0500
In-Reply-To: <1362664017-30275-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Thu,  7 Mar 2013 15:46:51 +0200

> Here's a batch of fixes to the mlx4 core and ethernet drivers for 3.9
> 
> The commit that disabled RFS when running in SRIOV mode fixes a regression which was 
> introduced in 3.9-rc1 but actually present also in the 3.8 -stable series. It turns out 
> that a slightly different fix is needed there and we will generate and submit it there.
> 
> Patches done against net commit 66d29cbc59433 "benet: Wait f/w POST until timeout"

Series applied, thanks.
