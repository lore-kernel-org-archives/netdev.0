From: Phil Hofer <philhofer@igneoussystems.com>
Subject: Re: [PATCH] improve mvneta (Marvell 370) driver TCPv6 performance
Date: Fri, 26 Jun 2015 12:57:54 -0700
Message-ID: <CAEvQe-Ts12i+C_hvBCByX_E+5XxDrrWZU-Ki5az5LmeEagOWgw@mail.gmail.com>
References: <CAEvQe-SY9N3k95BBkq75N4Rz8jfv+t7Q7Bh1ZSEtdHqDQmX2+Q@mail.gmail.com>
	<20150626205200.64169c49@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Oren Laskin <orenlaskin@igneoussystems.com>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:34912 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752633AbbFZT5y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2015 15:57:54 -0400
Received: by iebrt9 with SMTP id rt9so82498815ieb.2
        for <netdev@vger.kernel.org>; Fri, 26 Jun 2015 12:57:54 -0700 (PDT)
In-Reply-To: <20150626205200.64169c49@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

My apologies.

I have a follow-up on the way with some of Willy's suggested changes as well.

On Fri, Jun 26, 2015 at 11:52 AM, Thomas Petazzoni
<thomas.petazzoni@free-electrons.com> wrote:
> Hello Phil,
>
> On Fri, 26 Jun 2015 11:12:03 -0700, Phil Hofer wrote:
>> TCP performance over IPv6 was only about 60% of IPv4 performance. This
>> patch makes up most (but not all) of the difference.
>>
>> Signed off by: Thomas Petazzoni (thomas.petazzoni@free-electrons.com)
>
> What makes you think you can use my Signed-off-by for a patch that I
> haven't written? It should be your Signed-off-by here, certainly not
> mine.
>
> Also, the e-mail address should be between <...>, not between (...).
>
> Thanks!
>
> Thomas
> --
> Thomas Petazzoni, CTO, Free Electrons
> Embedded Linux, Kernel and Android engineering
> http://free-electrons.com
