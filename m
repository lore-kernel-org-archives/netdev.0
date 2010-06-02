From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] IP: Increment INADDRERRORS if routing for a packet is
 not successful
Date: Wed, 2 Jun 2010 11:27:17 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1006021126500.30182@router.home>
References: <alpine.DEB.2.00.1006021025200.30182@router.home> <1275492754.2725.192.camel@edumazet-laptop> <alpine.DEB.2.00.1006021103410.30182@router.home> <20100602.091909.113727983.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nlpi157.sbcis.sbc.com ([207.115.36.171]:33616 "EHLO
	nlpi157.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932580Ab0FBQ1Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 12:27:24 -0400
In-Reply-To: <20100602.091909.113727983.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2 Jun 2010, David Miller wrote:

> From: Christoph Lameter <cl@linux-foundation.org>
> Date: Wed, 2 Jun 2010 11:12:14 -0500 (CDT)
>
> > Its important to know why drops occur (any drops for that matter, drops
> > mean retransmit which means latency).
>
> We know, that's why there is a networking tracepoint that allows you
> to see where all drops occur. :-)

Where can I find out more about the network tracepoint?

