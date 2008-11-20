From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/33] Network Devices Ops (v0.3)
Date: Wed, 19 Nov 2008 22:37:40 -0800 (PST)
Message-ID: <20081119.223740.52256520.davem@davemloft.net>
References: <4924F3D9.3020908@cosmosbay.com>
	<20081119.212502.188042356.davem@davemloft.net>
	<20081120061540.GA2202@x200.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, shemminger@vyatta.com, netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48148
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752349AbYKTGhl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 01:37:41 -0500
In-Reply-To: <20081120061540.GA2202@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Thu, 20 Nov 2008 09:15:40 +0300

> On Wed, Nov 19, 2008 at 09:25:02PM -0800, David Miller wrote:
> > From: Eric Dumazet <dada1@cosmosbay.com>
> > Date: Thu, 20 Nov 2008 06:21:29 +0100
> > 
> > > So if you plan to release a new release of Network Device Ops...
> > > 
> > > I would have one suggestion about these ops, that would be to prefix
> > > method names (open, close, ...) by a ndo_ or something that ease greping...
> > 
> > Since I'm in the process of integrating this work, I'll take care
> > of doing this.  It definitely sounds like a good idea to me.
> 
> Can use just "nd_".

Already used by ocfs and others.
