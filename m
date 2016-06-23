From: David Miller <davem@davemloft.net>
Subject: Re: of_mdio: Enable fixed PHY support if driver is a module
Date: Thu, 23 Jun 2016 15:10:14 -0400 (EDT)
Message-ID: <20160623.151014.278983057518765383.davem@davemloft.net>
References: <1466467855.26723.16.camel@codethink.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, linux-kernel@lists.codethink.co.uk,
	netdev@vger.kernel.org
To: ben.hutchings@codethink.co.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34834 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751390AbcFWTKV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2016 15:10:21 -0400
In-Reply-To: <1466467855.26723.16.camel@codethink.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Date: Tue, 21 Jun 2016 01:10:55 +0100

> The fixed_phy driver doesn't have to be built-in, and it's
> important that of_mdio supports it even if it's a module.
> 
> Signed-off-by: Ben Hutchings <ben.hutchings@codethink.co.uk>

Applied.
