From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: MULTIPLE_TABLES and IP_ADVANCED_ROUTER
Date: Tue, 24 Nov 2015 19:38:13 +0100
Message-ID: <CAMuHMdUvOZGPpR9ipNd=OxpWsHcDSbSiX+=HG1nxOJKSpeOm6Q@mail.gmail.com>
References: <CAMuHMdXZpxnrU=FfFcf3sgX+Ym3RCVLA7dn_8mgUBpby18uDzw@mail.gmail.com>
	<20151124.131025.2229181704954661538.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:32830 "EHLO
	mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754278AbbKXSiO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 13:38:14 -0500
Received: by oixx65 with SMTP id x65so15341775oix.0
        for <netdev@vger.kernel.org>; Tue, 24 Nov 2015 10:38:13 -0800 (PST)
In-Reply-To: <20151124.131025.2229181704954661538.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Tue, Nov 24, 2015 at 7:10 PM, David Miller <davem@davemloft.net> wrote:
> From: Geert Uytterhoeven <geert@linux-m68k.org>
> Date: Sun, 22 Nov 2015 11:03:18 +0100
>
>> Is there a reason why IP_MULTIPLE_TABLES and
>> IP_MROUTE_MULTIPLE_TABLES depend on IP_ADVANCED_ROUTER, while their
>> IPV6 counterparts don't?
>
> It's just another thing that happened to diverge over time, there is
> no real reason.

So should the dependencies be added for IPv6, or removed for IPv4?
Thanks again!

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
