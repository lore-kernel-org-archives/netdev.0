From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netdev/phy: Prototype of_mdio_find_bus()
Date: Tue, 09 Oct 2012 13:55:44 -0400 (EDT)
Message-ID: <20121009.135544.1728726032831568483.davem@davemloft.net>
References: <1349772944-14289-1-git-send-email-broonie@opensource.wolfsonmicro.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: david.daney@cavium.com, netdev@vger.kernel.org
To: broonie@opensource.wolfsonmicro.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39460 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752609Ab2JIRzq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2012 13:55:46 -0400
In-Reply-To: <1349772944-14289-1-git-send-email-broonie@opensource.wolfsonmicro.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Date: Tue,  9 Oct 2012 17:55:43 +0900

> Ensure that of_mdio_find_bus() matches the prototype in the header (and
> stop sparse complaining) by including the header with the prototype.
> 
> Signed-off-by: Mark Brown <broonie@opensource.wolfsonmicro.com>

Applied.
