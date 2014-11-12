From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] net: phy: bcm7xxx: workaround updates
Date: Wed, 12 Nov 2014 14:08:57 -0500 (EST)
Message-ID: <20141112.140857.1216703516679476771.davem@davemloft.net>
References: <1415746514-11189-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45433 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753368AbaKLTJA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2014 14:09:00 -0500
In-Reply-To: <1415746514-11189-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Tue, 11 Nov 2014 14:55:09 -0800

> This patch series contains some updates to the Broadcom BCM7xxx internal
> PHY driver, including:
> 
> - removing an annonying print that would appear during interface up/down and
>   suspend/resume cycles
> - drop a workaround sequence for a non-production PHY revision
> - add new workarounds for the latest and greatest PHY devices found out ther

Applied, thanks Florian.
