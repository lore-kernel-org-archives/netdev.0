From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phy: micrel: add of configuration for LED mode
Date: Wed, 26 Feb 2014 17:00:57 -0500 (EST)
Message-ID: <20140226.170057.1058889232520320973.davem@davemloft.net>
References: <1393415280-10227-1-git-send-email-ben.dooks@codethink.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@lists.codethink.co.uk, devicetree@vger.kernel.org,
	netdev@vger.kernel.org, f.fainelli@gmail.com
To: ben.dooks@codethink.co.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41345 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751929AbaBZWBr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 17:01:47 -0500
In-Reply-To: <1393415280-10227-1-git-send-email-ben.dooks@codethink.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Dooks <ben.dooks@codethink.co.uk>
Date: Wed, 26 Feb 2014 11:48:00 +0000

> Add support for the led-mode property for the following PHYs
> which have a single LED mode configuration value.
> 
> KSZ8001 and KSZ8041 which both use register 0x1e bits 15,14 and
> KSZ8021, KSZ8031 and KSZ8051 which use register 0x1f bits 5,4
> to control the LED configuration.
> 
> Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>

Applied, thanks.
