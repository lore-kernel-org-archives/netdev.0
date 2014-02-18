From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/6] gianfar: Device configuration fixes
Date: Tue, 18 Feb 2014 15:03:26 -0500 (EST)
Message-ID: <20140218.150326.345866777429417518.davem@davemloft.net>
References: <1392634399-5456-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: claudiu.manoil@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35207 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751162AbaBRUDb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Feb 2014 15:03:31 -0500
In-Reply-To: <1392634399-5456-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Claudiu Manoil <claudiu.manoil@freescale.com>
Date: Mon, 17 Feb 2014 12:53:13 +0200

> This patchset represents the first part of an effort
> to solve some old device configuration issues in gianfar,
> especially run-time reset and re-configuration problems.
> I'm referring to "on-the-fly" configuration of registers
> against HW specification, concurrency issues during device
> reset / re-configuration operations, and implementing HW
> advisories for these operations.
> 
> There's also a good deal of code cleanup and refactoring,
> and some other (minor) fixes as well.
> 
> Thank you. 

Series applied, thanks.
