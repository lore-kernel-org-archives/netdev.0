From: jamal <hadi@cyberus.ca>
Subject: Re: [take28-resend_1->0 0/8] kevent: Generic event handling
	mechanism.
Date: Thu, 21 Dec 2006 08:48:05 -0500
Message-ID: <1166708885.3749.49.camel@localhost>
References: <3154985aa0591036@2ka.mipt.ru> <11666924573643@2ka.mipt.ru>
	 <20061221103539.GA4099@2ka.mipt.ru> <458A64E5.4050703@garzik.org>
	 <20061221104918.GA16744@2ka.mipt.ru>
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
Received: from nz-out-0506.google.com ([64.233.162.226]:47776 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422944AbWLUNsJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Dec 2006 08:48:09 -0500
Received: by nz-out-0506.google.com with SMTP id s1so984758nze
        for <netdev@vger.kernel.org>; Thu, 21 Dec 2006 05:48:08 -0800 (PST)
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20061221104918.GA16744@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy,

On Thu, 2006-21-12 at 13:49 +0300, Evgeniy Polyakov wrote:

> So comment on its bugs, its design, implementation, ask questions,
> request features, show interest (even with 'I have no time right now,
> but will loko at it after in a week after vacations').
> 
> No one does it, so no one cares, so my behaviour.
> 

Please dont be discouraged by lack of attention - you are doing good
work.

I will concur with Jeff's point that since you are putting out a
profound conceptual changes, and there are many stake holders, it
requires scrutiny on their part. You need to build consensus in such a
situation. 
Some things that would help progress and build momentum:
- As i have advised you before, why dont you modify something like
existing libraries such as some of the loop thingies of desktop managers
such as kde/gnome or better things like libevent etc. Then write your
app on top of that? nobody is gonna run your httpd but if you
demonstrate that libevent is much better with your changes (with zero
changes to apps), people will migrate
- from a user space angle if people like Ulrich would state their views
on the current version you have. 
Note, they dont have to agree with you i.e the conclusion could be a
simple "agree to disagree".
- There really oughta be a limit on how long people are allowed to be
silent. After that IMO your code should just go in ...
 

cheers,
jamal

