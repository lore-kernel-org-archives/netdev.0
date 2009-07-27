From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net: shrink net_device by #ifdef-ing protocol-specific
 members
Date: Mon, 27 Jul 2009 09:33:53 -0700
Message-ID: <1248712434.10463.111.camel@Joe-Laptop.home>
References: <4A6DC314.2010303@ixiacom.com>
	 <20090727.082644.265102452.davem@davemloft.net>
	 <1248711781.10463.108.camel@Joe-Laptop.home>
	 <20090727.092712.84381944.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: lgrijincu@ixiacom.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.LABridge.com ([206.117.136.22]:3366 "EHLO
	mail.perches.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752038AbZG0Qd4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2009 12:33:56 -0400
In-Reply-To: <20090727.092712.84381944.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-07-27 at 09:27 -0700, David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Mon, 27 Jul 2009 09:23:01 -0700
> > I think the cost of maintaining this is small and the
> > percentage of users that benefit underestimated.
> Prove it.

Cost/bit/knot valuations are arbitrary.

cheers, Joe


