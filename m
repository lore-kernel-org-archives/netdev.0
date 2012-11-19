From: David Miller <davem@davemloft.net>
Subject: Re: [GIT PULL] Marvell mvneta Ethernet/MDIO drivers checkpatch
 fixes
Date: Mon, 19 Nov 2012 14:16:53 -0500 (EST)
Message-ID: <20121119.141653.1660827388689535803.davem@davemloft.net>
References: <1353322834-16952-1-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jason@lakedaemon.net, andrew@lunn.ch,
	gregory.clement@free-electrons.com,
	linux-arm-kernel@lists.infradead.org, alior@marvell.com,
	netdev@vger.kernel.org
To: thomas.petazzoni@free-electrons.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60545 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754105Ab2KSTQz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 14:16:55 -0500
In-Reply-To: <1353322834-16952-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Date: Mon, 19 Nov 2012 12:00:31 +0100

> Sebastian Hesselbarth noticed that the new mvmdio and mvneta drivers
> produce a number of checkpatch warnings, related to the incluse of
> <asm/delay.h> and to the style of multiline comments. The following
> three patches fix those checkpatch warnings. Feel free to integrate
> them either as follow-up patches of the network driver patches, or to
> squash them into the driver patches as you prefer.
> 
> David, are you OK with those patches and the fact that we carry them
> through the arm-soc tree, as we agreed to do for the mvmdio and mvneta
> drivers? Those patches are really simple/stupid fixes.

No problem, thanks.
