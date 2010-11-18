From: Marcos <stalkingtime@gmail.com>
Subject: Re: Fwd: a Great Idea - include Kademlia networking protocol in
 kernel -- REVISITED
Date: Thu, 18 Nov 2010 15:21:25 -0700
Message-ID: <AANLkTik-oLx5B2t0E3XKsseHi7tJF2hDMkOw21Mt=i0F@mail.gmail.com>
References: <AANLkTi=VgBQ5rwkjZeo2zsRx1dSBy+4PBXeLLPQ4LRES@mail.gmail.com>
	<AANLkTinWUmQ91cCULC8ZXFLwSKz6SNt3BpszrBEhbgcu@mail.gmail.com>
	<1289724643.2743.58.camel@edumazet-laptop>
	<AANLkTimkPpWob8ANySeWBvDE+Pq2wy4SQWJOSYzbS7QG@mail.gmail.com>
	<1289727544.2743.72.camel@edumazet-laptop>
	<AANLkTimoZRYssbop-JhryUVae5zy+KFsxny9T4ssHnqE@mail.gmail.com>
	<AANLkTi=RQjvwpTwZtkjcyjgMVsZbYfi=34wSd-_JE3pP@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Honglei Cong <conghonglei@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:40611 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756160Ab0KRWV1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Nov 2010 17:21:27 -0500
Received: by bwz15 with SMTP id 15so3268104bwz.19
        for <netdev@vger.kernel.org>; Thu, 18 Nov 2010 14:21:26 -0800 (PST)
In-Reply-To: <AANLkTi=RQjvwpTwZtkjcyjgMVsZbYfi=34wSd-_JE3pP@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> Yes, of course, all that will have to be considered. =A0 But I'm
>> suggesting that such a move is an investment in the future, that the
>> the number of machines that will want or request peer-2-peer
>> connectivity will (or should) only increase. =A0Done right, such a m=
ove
>> should *simplify* things. =A0We're biased to think in centralized wa=
ys
>> because of the centuries-old history of *who* has the resources. =A0=
But
>> as networking, computation, and storage become commodified further,
>> whole new topologies for the *right* architecture become available.
>> The idea of "the OS" itself morphs. =A0 And the *only* way maximize =
the
> Agree with u. =A0But 'kernel' is not.

=2E..Consider a unified model of two orthogonal resources: processor --
memory.  In theory such a unified model should be realizable.  For
example, if we fix the processor side (say the user's machine), then
you can move around the memory side, unify different memory stores:
cache, RAM, local HD, Networked file storage (naturally logarithmic
scaling).  There's no more need to "install applications":  it's all
installed out there somewhere (probably from the same place where it
was created), you just need to "page it in".  Create an abstract,
user-controlled, peer grouping model that allows arbitrary "trust (or
privacy) groups" where "node discovery" (say new annoucements) and
"shared memory" is allowed and watch the Social Linux Network Brain
evolve.  (I better not even mention an integrated voting model
yet....)

Too idealistic?

marcos
pangaia.sourceforge.net
