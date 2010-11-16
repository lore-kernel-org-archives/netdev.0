From: Honglei Cong <conghonglei@gmail.com>
Subject: Re: Fwd: a Great Idea - include Kademlia networking protocol in
 kernel -- REVISITED
Date: Wed, 17 Nov 2010 00:11:00 +0800
Message-ID: <AANLkTi=RQjvwpTwZtkjcyjgMVsZbYfi=34wSd-_JE3pP@mail.gmail.com>
References: <AANLkTi=VgBQ5rwkjZeo2zsRx1dSBy+4PBXeLLPQ4LRES@mail.gmail.com>
	<AANLkTinWUmQ91cCULC8ZXFLwSKz6SNt3BpszrBEhbgcu@mail.gmail.com>
	<1289724643.2743.58.camel@edumazet-laptop>
	<AANLkTimkPpWob8ANySeWBvDE+Pq2wy4SQWJOSYzbS7QG@mail.gmail.com>
	<1289727544.2743.72.camel@edumazet-laptop>
	<AANLkTimoZRYssbop-JhryUVae5zy+KFsxny9T4ssHnqE@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Marcos <stalkingtime@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:54378 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754377Ab0KPQLD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Nov 2010 11:11:03 -0500
Received: by iwn35 with SMTP id 35so965854iwn.19
        for <netdev@vger.kernel.org>; Tue, 16 Nov 2010 08:11:02 -0800 (PST)
In-Reply-To: <AANLkTimoZRYssbop-JhryUVae5zy+KFsxny9T4ssHnqE@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 16, 2010 at 2:21 PM, Marcos <stalkingtime@gmail.com> wrote:
> [Eric Dumazet wrote:]
>> But we dont want a "super operating system". We want a good one.
>
> Yes, well you have that, I think, speaking at the kernel level. =A0Bu=
t
> the thing is, people are building tools that mimic such anyway, and
> the next wave of new value will be found there.
>
>> Memory stores done in userland are as fast as memory stores done in
>> kernel.
>
> Really? And how about the abstraction-level? =A0because that will eit=
her
> make it lucrative or not for developers to build applications for
> it.....
>
>> Once you need to access files, perform complex searches, timers,
>> logging, and all the stuff, you really want to do it from userland, =
in
>> high level language that many programmers master, or get something t=
hat
>> is too complex/buggy.
>
> Yes, of course, all that will have to be considered. =A0 But I'm
> suggesting that such a move is an investment in the future, that the
> the number of machines that will want or request peer-2-peer
> connectivity will (or should) only increase. =A0Done right, such a mo=
ve
> should *simplify* things. =A0We're biased to think in centralized way=
s
> because of the centuries-old history of *who* has the resources. =A0B=
ut
> as networking, computation, and storage become commodified further,
> whole new topologies for the *right* architecture become available.
> The idea of "the OS" itself morphs. =A0 And the *only* way maximize t=
he
Agree with u.  But 'kernel' is not.

> value of the network is to make it easy to connect and communicate
> between peers -- what happens after that is so radical it can hardly
> be speculated because it gets into the realm of emergent complexity.
> Again, I refer you to Reed's law on the value of such networks.
>
> marcos
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
