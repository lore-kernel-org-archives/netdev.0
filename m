From: Marcos <stalkingtime@gmail.com>
Subject: Re: Fwd: a Great Idea - include Kademlia networking protocol in
 kernel -- REVISITED
Date: Mon, 15 Nov 2010 23:21:19 -0700
Message-ID: <AANLkTimoZRYssbop-JhryUVae5zy+KFsxny9T4ssHnqE@mail.gmail.com>
References: <AANLkTi=VgBQ5rwkjZeo2zsRx1dSBy+4PBXeLLPQ4LRES@mail.gmail.com>
	<AANLkTinWUmQ91cCULC8ZXFLwSKz6SNt3BpszrBEhbgcu@mail.gmail.com>
	<1289724643.2743.58.camel@edumazet-laptop>
	<AANLkTimkPpWob8ANySeWBvDE+Pq2wy4SQWJOSYzbS7QG@mail.gmail.com>
	<1289727544.2743.72.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:52346 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755529Ab0KPGVV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Nov 2010 01:21:21 -0500
Received: by bwz15 with SMTP id 15so323293bwz.19
        for <netdev@vger.kernel.org>; Mon, 15 Nov 2010 22:21:20 -0800 (PST)
In-Reply-To: <1289727544.2743.72.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Eric Dumazet wrote:]
> But we dont want a "super operating system". We want a good one.

Yes, well you have that, I think, speaking at the kernel level.  But
the thing is, people are building tools that mimic such anyway, and
the next wave of new value will be found there.

> Memory stores done in userland are as fast as memory stores done in
> kernel.

Really? And how about the abstraction-level?  because that will either
make it lucrative or not for developers to build applications for
it.....

> Once you need to access files, perform complex searches, timers,
> logging, and all the stuff, you really want to do it from userland, in
> high level language that many programmers master, or get something that
> is too complex/buggy.

Yes, of course, all that will have to be considered.   But I'm
suggesting that such a move is an investment in the future, that the
the number of machines that will want or request peer-2-peer
connectivity will (or should) only increase.  Done right, such a move
should *simplify* things.  We're biased to think in centralized ways
because of the centuries-old history of *who* has the resources.  But
as networking, computation, and storage become commodified further,
whole new topologies for the *right* architecture become available.
The idea of "the OS" itself morphs.   And the *only* way maximize the
value of the network is to make it easy to connect and communicate
between peers -- what happens after that is so radical it can hardly
be speculated because it gets into the realm of emergent complexity.
Again, I refer you to Reed's law on the value of such networks.

marcos
