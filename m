From: Greg KH <greg@kroah.com>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference at
 000000000000002c
Date: Mon, 30 Jan 2012 09:12:15 -0800
Message-ID: <20120130171215.GA11508@kroah.com>
References: <1322773527.2750.27.camel@edumazet-laptop>
 <4ED86B79.4060506@profihost.ag>
 <4EE25B06.7010907@profihost.ag>
 <20111209.142117.357254752872525966.davem@davemloft.net>
 <4EE32076.2020706@profihost.ag>
 <4F26571E.1010002@profihost.ag>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	jwboyer@gmail.com, hch@infradead.org, netdev@vger.kernel.org,
	david@fromorbit.com, stable@vger.kernel.org, gregkh@suse.de
To: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:41427 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752690Ab2A3RMi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2012 12:12:38 -0500
Received: from compute3.internal (compute3.nyi.mail.srv.osa [10.202.2.43])
	by gateway1.nyi.mail.srv.osa (Postfix) with ESMTP id E2A6C204A8
	for <netdev@vger.kernel.org>; Mon, 30 Jan 2012 12:12:37 -0500 (EST)
Content-Disposition: inline
In-Reply-To: <4F26571E.1010002@profihost.ag>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 30, 2012 at 09:38:54AM +0100, Stefan Priebe - Profihost AG wrote:
> Hi David, Hi Greg, Hi List,
> 
> Am 10.12.2011 10:03, schrieb Stefan Priebe:
> > Am 09.12.2011 20:21, schrieb David Miller:
> >> From: Stefan Priebe<s.priebe@profihost.ag>
> >> Date: Fri, 09 Dec 2011 20:01:26 +0100
> >>
> >>> any news on that? Systems still crashing every now and then. 3.0.13
> >>> was released today but i haven't seen any of them.
> >>
> >> I only had time to submit these fixes for 3.1.x-stable, you'll just
> >> have to be incredibly patient.
> 
> this bug sadly still makes the actual STABLE tree of the kernel
> unusable. I mean nearly everbody uses TCP/IP.

"this bug"?

Please be more specific, as I have no idea what you are referring to.
Especially when you reference an email from 4 months ago, my brain's
stack size is 4 hours tops...

greg k-h
