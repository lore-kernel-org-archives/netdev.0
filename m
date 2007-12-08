From: David Miller <davem@davemloft.net>
Subject: Re: [patch 3/3][IPV6]: route6 remove ifdef for fib_rules
Date: Sat, 08 Dec 2007 00:15:18 -0800 (PST)
Message-ID: <20071208.001518.217775480.davem@davemloft.net>
References: <20071207131325.332768305@ICON-9-164-138-215.megacenter.de.ibm.com>
	<20071207131813.975600292@ICON-9-164-138-215.megacenter.de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, pekkas@netcore.fi, netdev@vger.kernel.org
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45083
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754173AbXLHIPT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Dec 2007 03:15:19 -0500
In-Reply-To: <20071207131813.975600292@ICON-9-164-138-215.megacenter.de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <dlezcano@fr.ibm.com>
Date: Fri, 07 Dec 2007 14:13:28 +0100

> The patch defines the usual static inline functions when the code is
> disabled for fib6_rules. That's allow to remove some ifdef in route.c
> file and make the code a little more clear.
> 
> Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

Applied, thanks.
