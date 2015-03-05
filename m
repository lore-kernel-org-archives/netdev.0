From: Dave Taht <dave.taht@gmail.com>
Subject: Re: I can tell no FIB
Date: Thu, 5 Mar 2015 13:01:20 -0800
Message-ID: <CAA93jw5oMK-KC-EkG71LKThqQxsHYcft+OHuu=APzjLdWSuO4g@mail.gmail.com>
References: <CAE4R7bBwrB8==aYuN9gYoADwZHDwr5zYjL3tL=jqPP24p74VUw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "alexander.h.duyck@redhat.com" <alexander.h.duyck@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:34423 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753388AbbCEVBU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 16:01:20 -0500
Received: by obcwp18 with SMTP id wp18so5278936obc.1
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2015 13:01:20 -0800 (PST)
In-Reply-To: <CAE4R7bBwrB8==aYuN9gYoADwZHDwr5zYjL3tL=jqPP24p74VUw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 5, 2015 at 12:49 PM, Scott Feldman <sfeldma@gmail.com> wrot=
e:
> Hi Alex, turns out you're required to take a mandatory week-long
> vacation after your fourth patch set to net/ipv4/fib_*.  See you in a
> week!  Take lots of pictures.

+10!

Is anyone here working on testing the new FIB stuff on itty bitty 32
bit platforms? It looks really promising
but openwrt is stabilizing on 3.18 and the prospect of backporting all
this stuff to that to test at scale is intimidating. (*I* am willing
to wait for 4.2)

But boy, could openwrt test at scale:

https://downloads.openwrt.org/snapshots/trunk/

>
> -scott
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



--=20
Dave T=C3=A4ht
Let's make wifi fast, less jittery and reliable again!

https://plus.google.com/u/0/107942175615993706558/posts/TVX3o84jjmb
