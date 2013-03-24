From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] dsa: add device tree bindings to register DSA
 switches
Date: Sun, 24 Mar 2013 17:17:38 -0400 (EDT)
Message-ID: <20130324.171738.301089541347666424.davem@davemloft.net>
References: <2044972.NvctqPqDPo@bender>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: devicetree-discuss@lists.ozlabs.org, rob.herring@calxeda.com,
	grant.likely@secretlab.ca, thomas.petazzoni@free-electrons.com,
	gregory.clement@free-electrons.com, jason@lakedaemon.net,
	buytenh@wantstofly.org, netdev@vger.kernel.org, andrew@lunn.ch,
	linux-arm-kernel@lists.infradead.org
To: florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43879 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754758Ab3CXVRk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Mar 2013 17:17:40 -0400
In-Reply-To: <2044972.NvctqPqDPo@bender>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <florian@openwrt.org>
Date: Fri, 22 Mar 2013 21:50:50 +0100

> This patch adds support for registering DSA switches using Device Tree
> bindings. Note that we support programming the switch routing table even
> though no in-tree user seems to require it. I tested this on Armada 370
> with a Marvell 88E6172 (not supported by mainline yet).
> 
> Signed-off-by: Florian Fainelli <florian@openwrt.org>

Applied.
