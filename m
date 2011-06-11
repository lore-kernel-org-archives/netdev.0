From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: DM9000: Add support for byte EEPROM access
Date: Sat, 11 Jun 2011 15:55:11 -0700 (PDT)
Message-ID: <20110611.155511.378086413275108077.davem@davemloft.net>
References: <1307703032-20349-1-git-send-email-broonie@opensource.wolfsonmicro.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ben-linux@fluff.org
To: broonie@opensource.wolfsonmicro.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47215 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752210Ab1FKWzb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2011 18:55:31 -0400
In-Reply-To: <1307703032-20349-1-git-send-email-broonie@opensource.wolfsonmicro.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Date: Fri, 10 Jun 2011 11:50:32 +0100

> From: Ben Dooks <ben-linux@fluff.org>
> 
> Given many versions of ethtool's reluctance to do anything other than
> byte accesses to the EEPROM interface, it is easier to update the driver
> to support byte accesses so that all the ethtool versions that have been
> observed in Debian can write the EEPROM.
> 
> Signed-off-by: Ben Dooks <ben-linux@fluff.org>
> Signed-off-by: Mark Brown <broonie@opensource.wolfsonmicro.com>

Applied to net-next-2.6, thanks.
