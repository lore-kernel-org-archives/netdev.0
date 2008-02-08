From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [NETNS] Remove unused member (dst_net) of dst_ops.
Date: Fri, 08 Feb 2008 04:45:44 -0800 (PST)
Message-ID: <20080208.044544.26552205.davem@davemloft.net>
References: <eb3ff54b0802080324i4c7df923y3476faa34392279a@mail.gmail.com>
	<1202470574.31674.24.camel@iris.sw.ru>
	<47AC4C2D.1030500@fr.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: den@openvz.org, ramirose@gmail.com, netdev@vger.kernel.org
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50293
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751648AbYBHMpN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2008 07:45:13 -0500
In-Reply-To: <47AC4C2D.1030500@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <dlezcano@fr.ibm.com>
Date: Fri, 08 Feb 2008 13:33:49 +0100

> Denis V. Lunev wrote:
> > This has been added by the Daniel Lezcano <dlezcano@fr.ibm.com> in the
> > commit d4fa26ff44e31c2636a985e3092e2cd55d8045de. It looks to me a
> > preparatory staff for IPv6 namespacing.
> > 
> > I think this is not needed in 2.6.25  but will be required in 2.6.26
> > very soon.
> 
> Yes, this is right, I posted this one just before sending ipv6 routing.
> Unfortunately, I posted ipv6 routing per namespace when net-2.6.25 closed.
> 
> We can remove it for net-2.6 and I can repost it for net-2.6.26, if you 
> want. Or we can just keep it ...

Let's just keep it in there for now.
