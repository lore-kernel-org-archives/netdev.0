From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: oopses since "net: Optimize memory usage when splicing from
	sockets"
Date: Thu, 30 Apr 2009 14:47:05 +0200
Message-ID: <20090430124705.GA8589@ami.dom.local>
References: <20090430031626.GM14729@mail.wantstofly.org> <20090430084321.GA2753@ami.dom.local> <20090430124036.GN14729@mail.wantstofly.org> <20090430.054040.31760584.davem@davemloft.net> <20090430124542.GO14729@mail.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f163.google.com ([209.85.218.163]:45651 "EHLO
	mail-bw0-f163.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755590AbZD3MsP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2009 08:48:15 -0400
Received: by bwz7 with SMTP id 7so1778202bwz.37
        for <netdev@vger.kernel.org>; Thu, 30 Apr 2009 05:48:14 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090430124542.GO14729@mail.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 30, 2009 at 02:45:42PM +0200, Lennert Buytenhek wrote:
> On Thu, Apr 30, 2009 at 05:40:40AM -0700, David Miller wrote:
...
> > Thanks for testing Lennert.
> > 
> > I'll queue this up for -stable too.
> 
> I don't see this in 2.6.29, since the offending commit was merged
> after 2.6.29 AFAICS?

Yes, David had a very good intuition some time ago, and opposed my
-stable recommendation!

Thanks for this,
Jarek P.
