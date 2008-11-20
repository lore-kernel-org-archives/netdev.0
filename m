From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/33] Network Devices Ops (v0.3)
Date: Wed, 19 Nov 2008 21:25:02 -0800 (PST)
Message-ID: <20081119.212502.188042356.davem@davemloft.net>
References: <20081119.173353.251644773.davem@davemloft.net>
	<20081119190212.6d589358@extreme>
	<4924F3D9.3020908@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32965
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752776AbYKTFZD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 00:25:03 -0500
In-Reply-To: <4924F3D9.3020908@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 20 Nov 2008 06:21:29 +0100

> So if you plan to release a new release of Network Device Ops...
> 
> I would have one suggestion about these ops, that would be to prefix
> method names (open, close, ...) by a ndo_ or something that ease greping...

Since I'm in the process of integrating this work, I'll take care
of doing this.  It definitely sounds like a good idea to me.

