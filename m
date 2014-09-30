From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v6 00/10] ARM: Berlin: Ethernet support
Date: Tue, 30 Sep 2014 16:37:35 -0400 (EDT)
Message-ID: <20140930.163735.2099691931550261883.davem@davemloft.net>
References: <1412087296-18475-1-git-send-email-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sebastian.hesselbarth@gmail.com,
	alexandre.belloni@free-electrons.com,
	thomas.petazzoni@free-electrons.com, zmxu@marvell.com,
	jszhang@marvell.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: antoine.tenart@free-electrons.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49589 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751047AbaI3Uhj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 16:37:39 -0400
In-Reply-To: <1412087296-18475-1-git-send-email-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antoine Tenart <antoine.tenart@free-electrons.com>
Date: Tue, 30 Sep 2014 16:28:06 +0200

> This series introduce support for the Ethernet controller on Berlin SoCs,
> using the existing pxa168 Ethernet driver. In order to do this, DT
> support is added to the driver alongside some other modifications and
> fixes.
> 
> This has been tested on a Berlin BG2Q DMP board.

Applied to net-next, thanks.
