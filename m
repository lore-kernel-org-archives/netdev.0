From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] of_mdio: fix kernel-doc for of_phy_connect()
Date: Tue, 01 Mar 2016 17:42:06 -0500 (EST)
Message-ID: <20160301.174206.1719757265479404095.davem@davemloft.net>
References: <5235224.0MKSCt7puR@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: grant.likely@linaro.org, robh+dt@kernel.org,
	devicetree@vger.kernel.org, f.fainelli@gmail.com,
	netdev@vger.kernel.org, frowand.list@gmail.com
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42886 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751130AbcCAWmH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 17:42:07 -0500
In-Reply-To: <5235224.0MKSCt7puR@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Sun, 28 Feb 2016 22:50:59 +0300

> The 'flags' parameter of the of_phy_connect() function wasn't described
> in  the kernel-doc comment...
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> 
> ---
> The patch is against DaveM's 'net.git' repo.

Applied.
