From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/6] ipv6 - make fib6_init to return an error code
Date: Fri, 07 Dec 2007 00:41:21 -0800 (PST)
Message-ID: <20071207.004121.205693062.davem@davemloft.net>
References: <20071206135329.598202596@ICON-9-164-138-215.megacenter.de.ibm.com>
	<20071206140243.597293579@ICON-9-164-138-215.megacenter.de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, pekkas@netcore.fi, netdev@vger.kernel.org,
	benjamin.thery@bull.net
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59972
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750952AbXLGIlX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2007 03:41:23 -0500
In-Reply-To: <20071206140243.597293579@ICON-9-164-138-215.megacenter.de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <dlezcano@fr.ibm.com>
Date: Thu, 06 Dec 2007 14:53:30 +0100

> If there is an error in the initialization function, nothing is followed up
> to the caller. So I add a return value to be set for the init function.
> 
> Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
> Acked-by: Benjamin Thery <benjamin.thery@bull.net>

Applied.

Please format your header subject lines as:

	[patch N/M] [IPV6]: Blah blah blah.

Since this is what I edit them into anyways.

Thanks.
