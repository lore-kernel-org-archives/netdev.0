From: "George B." <georgeb@gmail.com>
Subject: Re: [PATCH] tcp: disallow bind() to reuse addr/port
Date: Wed, 27 Apr 2011 10:54:50 -0700
Message-ID: <BANLkTin-KhU0KqSuUpbCi2STnnxszO5x=Q@mail.gmail.com>
References: <1294140172.3579.81.camel@edumazet-laptop>
	<AANLkTimuNM7vmeR89WKXtrUbJO1Wt1ivp9y=bQvtWg0j@mail.gmail.com>
	<1294744462.2927.53.camel@edumazet-laptop>
	<20110111.140336.128591591.davem@davemloft.net>
	<BANLkTi=176iFKUHn351OWOZUSaUBkgKf2Q@mail.gmail.com>
	<1303926014.3166.101.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, daniel.baluta@gmail.com,
	gasparch@gmail.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:39863 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933105Ab1D0Ryw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2011 13:54:52 -0400
Received: by wwa36 with SMTP id 36so2172444wwa.1
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2011 10:54:50 -0700 (PDT)
In-Reply-To: <1303926014.3166.101.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>
>> OK, just saw this, so please disregard my earlier.
>
> Hmm... you'll discover this patch was reverted, because it broke some
> applications.
>
> So your problem remains.

Just to clarify, both the previous patch from last year *AND* this
patch in January were reverted?  I can't seem to find anything showing
the new one being reverted and am now confused.
