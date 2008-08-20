From: Josh Boyer <jwboyer@gmail.com>
Subject: Re: [GIT]: Networking
Date: Tue, 19 Aug 2008 22:25:15 -0400
Message-ID: <1219199116.26429.19.camel@jdub.homelinux.org>
References: <alpine.LFD.1.10.0808190952000.3324@nehalem.linux-foundation.org>
	 <1219170451.7591.175.camel@violet.holtmann.net>
	 <alpine.LFD.1.10.0808191348540.3324@nehalem.linux-foundation.org>
	 <20080819.142150.129314008.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, marcel@holtmann.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f16.google.com ([209.85.217.16]:50050 "EHLO
	mail-gx0-f16.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751768AbYHTCZl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 22:25:41 -0400
Received: by gxk9 with SMTP id 9so6039243gxk.13
        for <netdev@vger.kernel.org>; Tue, 19 Aug 2008 19:25:40 -0700 (PDT)
In-Reply-To: <20080819.142150.129314008.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-08-19 at 14:21 -0700, David Miller wrote:
> But it doesn't fix the time delegation problem.
> 
> There is always this "oh crap, I just spent 3 months doing nothing
> but fixing bugs" feeling a lot of us core folks get right before
> the merge window opens up.
> 
> So instead of getting the best work from the best people we have,
> we get this last minute flurry of development in the days leading
> up to the merge window openning up.

So, not to add fuel to a fire that seems to be calming down, but what is
so wrong with having that feeling?  If the core people are spending 3
months doing nothing but fixing bugs, the I consider that to _be_ the
best work from the best people.

Bugs happen and it's not really worth debating over how they got into
the tree to begin with because it happens in a number of different ways.
However, if it takes 3 months of bug fixing to get a tree in shape then
I don't see how that's a problem at all.  Personally, I'd rather take a
relatively bug free tree over new shiny features on top of a buggy as
hell tree.

Call me old fashioned.

josh

