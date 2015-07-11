From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: Pass mdix ethtool setting through to phy
 driver
Date: Fri, 10 Jul 2015 23:17:54 -0700 (PDT)
Message-ID: <20150710.231754.962399543255447273.davem@davemloft.net>
References: <1436493414-16248-1-git-send-email-david.thomson@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org
To: david.thomson@alliedtelesis.co.nz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55664 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752395AbbGKGRz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jul 2015 02:17:55 -0400
In-Reply-To: <1436493414-16248-1-git-send-email-david.thomson@alliedtelesis.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Thomson <david.thomson@alliedtelesis.co.nz>
Date: Fri, 10 Jul 2015 13:56:54 +1200

> Pass the mdix setting from ethtool down to the phy driver, to allow
> driver specific implementations of manually setting the polarity.
> 
> Signed-off-by: David Thomson <david.thomson@alliedtelesis.co.nz>

Applied to net-next.
