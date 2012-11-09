From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] phylib: mdio: Add sysfs attribute for PHY
 identifiers.
Date: Fri, 09 Nov 2012 16:38:43 -0500 (EST)
Message-ID: <20121109.163843.1150319256700686259.davem@davemloft.net>
References: <1352305234-22340-1-git-send-email-nbowler@elliptictech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nbowler@elliptictech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38559 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753714Ab2KIViq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2012 16:38:46 -0500
In-Reply-To: <1352305234-22340-1-git-send-email-nbowler@elliptictech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nick Bowler <nbowler@elliptictech.com>
Date: Wed,  7 Nov 2012 11:20:34 -0500

> This adds a phy_id sysfs attribute to MDIO devices, containing the
> 32-bit PHY identifier reported by the device.  This attribute can
> be useful when debugging problems related to phy drivers.  Other
> enumerable buses already have similar attributes.
> 
> Signed-off-by: Nick Bowler <nbowler@elliptictech.com>

Seems reasonable, applied, thanks.
