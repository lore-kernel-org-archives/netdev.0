From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: oopses since "net: Optimize memory usage when splicing from sockets"
Date: Thu, 30 Apr 2009 14:45:42 +0200
Message-ID: <20090430124542.GO14729@mail.wantstofly.org>
References: <20090430031626.GM14729@mail.wantstofly.org> <20090430084321.GA2753@ami.dom.local> <20090430124036.GN14729@mail.wantstofly.org> <20090430.054040.31760584.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jarkao2@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:41399 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756386AbZD3Mly (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2009 08:41:54 -0400
Content-Disposition: inline
In-Reply-To: <20090430.054040.31760584.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 30, 2009 at 05:40:40AM -0700, David Miller wrote:

> > With your patch, at least the oops is gone, and I guess it makes
> > sense and looks correct, so:
> > 
> > 	Tested-by: Lennert Buytenhek <buytenh@wantstofly.org>
> 
> Thanks for testing Lennert.
> 
> I'll queue this up for -stable too.

I don't see this in 2.6.29, since the offending commit was merged
after 2.6.29 AFAICS?
