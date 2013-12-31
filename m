From: Wei-Chun Chao <weichunc@plumgrid.com>
Subject: Re: [GIT] Networking
Date: Tue, 31 Dec 2013 00:05:52 -0800
Message-ID: <CACviX4GFbB4VY+TaZVghDrbmaWVz4eHh=3znF2i1w1eLODOT=Q@mail.gmail.com>
References: <CAJZOPZLciJ=X9_h9eqd0KrdkrOT6tKw93wFnmDKY6cQfG_4ZTw@mail.gmail.com>
	<20131230.195209.1342950946997239413.davem@davemloft.net>
	<CAJZOPZJo1oEkGDp+FiiNT81xs5jwH4uEaBDW8ywP5OAw185UCw@mail.gmail.com>
	<20131231.010554.335340250542861948.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Or Gerlitz <or.gerlitz@gmail.com>, netdev <netdev@vger.kernel.org>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f177.google.com ([209.85.128.177]:35293 "EHLO
	mail-ve0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751762Ab3LaIFx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Dec 2013 03:05:53 -0500
Received: by mail-ve0-f177.google.com with SMTP id db12so6162805veb.8
        for <netdev@vger.kernel.org>; Tue, 31 Dec 2013 00:05:52 -0800 (PST)
In-Reply-To: <20131231.010554.335340250542861948.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Mon, Dec 30, 2013 at 10:05 PM, David Miller <davem@davemloft.net> wrote:
> From: Or Gerlitz <or.gerlitz@gmail.com>
> Date: Tue, 31 Dec 2013 07:56:04 +0200
>
>> I am somehow under the impression that we are aligned on the initial
>> approach + your feedback addressed, so I missed something along the
>> way?
>
> ... sounds like you need to simply repost.

Hi Dave,
I reworked the patch according to your comments -
http://patchwork.ozlabs.org/patch/305310/

Though the v2 patch was against 'net' (as you requested). I wonder if
it is because of that the state has not moved forward from "Change
Requested"?

Thanks,
Weichun
