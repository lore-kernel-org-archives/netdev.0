From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH 00/33] Network Devices Ops (v0.3)
Date: Thu, 20 Nov 2008 09:15:40 +0300
Message-ID: <20081120061540.GA2202@x200.localdomain>
References: <20081119.173353.251644773.davem@davemloft.net> <20081119190212.6d589358@extreme> <4924F3D9.3020908@cosmosbay.com> <20081119.212502.188042356.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dada1@cosmosbay.com, shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:15685 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752266AbYKTGMB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 01:12:01 -0500
Received: by nf-out-0910.google.com with SMTP id d3so152536nfc.21
        for <netdev@vger.kernel.org>; Wed, 19 Nov 2008 22:11:56 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20081119.212502.188042356.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 19, 2008 at 09:25:02PM -0800, David Miller wrote:
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Thu, 20 Nov 2008 06:21:29 +0100
> 
> > So if you plan to release a new release of Network Device Ops...
> > 
> > I would have one suggestion about these ops, that would be to prefix
> > method names (open, close, ...) by a ndo_ or something that ease greping...
> 
> Since I'm in the process of integrating this work, I'll take care
> of doing this.  It definitely sounds like a good idea to me.

Can use just "nd_".
