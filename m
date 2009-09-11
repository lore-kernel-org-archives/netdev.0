From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] phy/marvell: Make non-aneg speed/duplex forcing
 work for 88E1111 PHYs
Date: Fri, 11 Sep 2009 12:19:43 -0700 (PDT)
Message-ID: <20090911.121943.267405662.davem@davemloft.net>
References: <20090910020130.GA31083@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: afleming@freescale.com, timur@freescale.com, leoli@freescale.com,
	galak@kernel.crashing.org, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: avorontsov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39458
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751925AbZIKTT1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2009 15:19:27 -0400
In-Reply-To: <20090910020130.GA31083@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Vorontsov <avorontsov@ru.mvista.com>
Date: Thu, 10 Sep 2009 06:01:30 +0400

> According to specs, when auto-negotiation is disabled, Marvell PHYs need
> a software reset after changing speed/duplex forcing bits. Otherwise,
> the modified bits have no effect.
> 
> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>

Applied.
