From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/4] Fix MDIO bus timeout issues on Dreamplug
Date: Tue, 29 Oct 2013 18:54:50 -0400 (EDT)
Message-ID: <20131029.185450.1734537211071455991.davem@davemloft.net>
References: <cover.1382637156.git.leigh@solinno.co.uk>
	<cover.1383038973.git.leigh@solinno.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com,
	sebastian.hesselbarth@gmail.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, jason@lakedaemon.net
To: leigh@solinno.co.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49513 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750971Ab3J2Wyw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 18:54:52 -0400
In-Reply-To: <cover.1383038973.git.leigh@solinno.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Leigh Brown <leigh@solinno.co.uk>
Date: Tue, 29 Oct 2013 09:33:30 +0000

> I think I have addressed all comments.
> 
> Changes since v2:
>  - Fix coding style in ordio_mdio_wait_ready, as identified by David
>  - Remove un-needed operator change in orion_mdio_write, as identified by David
> 
> This patchset fixes an issue with the Dreamplug MDIO bus timeout since the
> mv643xx_eth driver was converted to use the mvmdio driver to access the bus.

Series applied to net-next, thanks.
