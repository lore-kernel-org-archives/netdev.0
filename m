From: jamal <hadi@cyberus.ca>
Subject: Re: [take28-resend_1->0 0/8] kevent: Generic event handling
	mechanism.
Date: Thu, 21 Dec 2006 09:21:07 -0500
Message-ID: <1166710867.3749.56.camel@localhost>
References: <3154985aa0591036@2ka.mipt.ru> <11666924573643@2ka.mipt.ru>
	 <20061221103539.GA4099@2ka.mipt.ru> <458A64E5.4050703@garzik.org>
	 <20061221104918.GA16744@2ka.mipt.ru> <1166708885.3749.49.camel@localhost>
	 <20061221140429.GA25214@2ka.mipt.ru>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.237]:57272 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753239AbWLUOVL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Dec 2006 09:21:11 -0500
Received: by nz-out-0506.google.com with SMTP id s1so989144nze
        for <netdev@vger.kernel.org>; Thu, 21 Dec 2006 06:21:10 -0800 (PST)
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20061221140429.GA25214@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-21-12 at 17:04 +0300, Evgeniy Polyakov wrote:

> I modified world-wide used web server lighttpd and ran a lot of tests
> with it (compared to epoll version with major performance win).
> 
> I was asked yesterday by Jan Kneschke (lighttpd main developer) if
> kevent API is ready so he could include my patch into mainline lighttpd 
> tree, but I answered 'I do not know if kevent will be or not included, 
> everyone keeps silence'.
> 

Ok, so you are building the momentum then. People like Jan are the users
of such API and should be speaking up. Then kernel people will be forced
to look at it.

> I just do not know _what_ else should be done not even for inclusion - 
> but at least for some progress.

I know you are frustrated but stop doing the above like a broken vinyl
record, it doesnt help your case. 

> You want libevent to be patched? Its site is currently down, but ok, I
> will create a patch.
> 

I promise in 2 weeks to migrate an app or two that i have that use
libevent to your version if you have it by then. I will then test and
give you my opinion. 

cheers,
jamal

