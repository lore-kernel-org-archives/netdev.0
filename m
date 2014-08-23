From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/7] net: phy: bcm7xxx: APD and EEE support
Date: Sat, 23 Aug 2014 11:39:49 -0700 (PDT)
Message-ID: <20140823.113949.463380064804211035.davem@davemloft.net>
References: <1408758945-18908-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35524 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752726AbaHWSju (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Aug 2014 14:39:50 -0400
In-Reply-To: <1408758945-18908-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Fri, 22 Aug 2014 18:55:38 -0700

> This patch series enables Auto-power down and EEE for the BCM7xxx integrated
> Gigabit PHYs.
> 
> I also put a fix for the fixed PHY that would allow clause 45 over clause 22
> reads/writes but would return bogus data by using e.g: ethtool --show-eee

Nice clean work as always, applied, thanks Florian.
