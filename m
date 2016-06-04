From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next 00/17] New DSA bind, switches as devices
Date: Sat, 04 Jun 2016 14:30:15 -0700 (PDT)
Message-ID: <20160604.143015.1678571971851827824.davem@davemloft.net>
References: <1465067829-1875-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
	netdev@vger.kernel.org, shawnguo@kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52172 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750753AbcFDVaT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jun 2016 17:30:19 -0400
In-Reply-To: <1465067829-1875-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Sat,  4 Jun 2016 21:16:50 +0200

> The interesting patches here are the last three. They implement a new
> binding for DSA, which removes a few limitations of the current DSA
> binding. In particular, it allows switches to be true Linux devices.
> These devices can be on any type of bus, unlike the old DSA binding
> which assumes MDIO. See the commit log for more details. The second to
> last patch modifies an existing boards device tree to use the new
> binding, giving a good example of how switches can be true MDIO
> devices. The last patch documents the new binding.
> 
> Thanks go to Florian and Vivien for reviewing, testing and bug fixing
> these patches.

Series applied, thanks Andrew.
