From: David Miller <davem@davemloft.net>
Subject: Re: [patch 3/6] ipv6 - make fib6_rules_init to return an error code
Date: Fri, 07 Dec 2007 00:43:03 -0800 (PST)
Message-ID: <20071207.004303.109949295.davem@davemloft.net>
References: <20071206135329.598202596@ICON-9-164-138-215.megacenter.de.ibm.com>
	<20071206140258.610073641@ICON-9-164-138-215.megacenter.de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, pekkas@netcore.fi, netdev@vger.kernel.org,
	benjamin.thery@bull.net
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59989
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750895AbXLGInE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2007 03:43:04 -0500
In-Reply-To: <20071206140258.610073641@ICON-9-164-138-215.megacenter.de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <dlezcano@fr.ibm.com>
Date: Thu, 06 Dec 2007 14:53:32 +0100

> When the fib_rules initialization finished, no return code is provided
> so there is no way to know, for the caller, if the initialization has
> been successful or has failed. This patch fix that.
> 
> Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
> Acked-by: Benjamin Thery <benjamin.thery@bull.net>

Applied, thanks.
