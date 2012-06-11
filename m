From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: =?utf-8?Q?net=2Fnetfilter=2Fnf=5Fconnt?=
	=?utf-8?B?cmFja19wcm90b190Y3AuYzoxNjA2Ojk6IGVycm9yOiDigJhzdHJ1Y3QgbmZf?=
	=?utf-8?B?cHJvdG9fbmV04oCZIGhhcyBubyBtZW1iZXIgbmFtZWQg4oCYdXNlcuKAmQ==?=
Date: Tue, 12 Jun 2012 00:46:20 +0200
Message-ID: <20120611224620.GA27507@1984>
References: <4fd664de.oQN9NTKjdledtla0%wfg@linux.intel.com>
 <20120611221521.GA27239@1984>
 <20120611.152344.1072167705198124284.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: wfg@linux.intel.com, gaofeng@cn.fujitsu.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44006 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751446Ab2FKWqX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jun 2012 18:46:23 -0400
Content-Disposition: inline
In-Reply-To: <20120611.152344.1072167705198124284.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 11, 2012 at 03:23:44PM -0700, David Miller wrote:
> From: Pablo Neira Ayuso <pablo@netfilter.org>
> Date: Tue, 12 Jun 2012 00:15:21 +0200
> 
> > Could you please apply the following patch to net-next to resolve
> > this? Thanks.
> 
> Applied, but you have to be kidding me with those ifdefs.
> 
> This is exactly the same kind of thing Gao suggested for
> the inetpeer code recently and which I flat out rejected.

Yes, this doesn't look nice at all...

> You can't pepper foo.c files with ifdefs all over the place.

I'll send patches to improve the current situation.
