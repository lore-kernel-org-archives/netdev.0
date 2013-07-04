From: Fernando Soto <fernando.soto@gmail.com>
Subject: Re: WARNING: at net/core/dst.c:274 dst_release+0x2d/0x56()
Date: Thu, 4 Jul 2013 11:56:07 -0400
Message-ID: <CADCFf2gS=m_X2WOVGdgUoKyGgdn1sD9HsBYhjikeMN05RExrOQ@mail.gmail.com>
References: <CADCFf2jAJRiHgMaMs8tNWSaonPmXg6q5C66iisdpuz9yMSAV+w@mail.gmail.com>
	<1372799622.4979.22.camel@edumazet-glaptop>
	<CADCFf2hEzwgtqfn4nHc4VwgT2+_XW9=uAos7Qo5YsEpRCWFO5Q@mail.gmail.com>
	<CADCFf2iUeyhnfhHET2Tbi1bM+7h=2LXLFvcerXHsz3Xv6E6zLw@mail.gmail.com>
	<1372950494.4979.97.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:42258 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754351Ab3GDP4I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jul 2013 11:56:08 -0400
Received: by mail-ob0-f175.google.com with SMTP id xn12so1779673obc.20
        for <netdev@vger.kernel.org>; Thu, 04 Jul 2013 08:56:08 -0700 (PDT)
In-Reply-To: <1372950494.4979.97.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm planning to run the same tests with 3.10. I'll post results once have them.
Thanks!

On Thu, Jul 4, 2013 at 11:08 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2013-07-04 at 08:21 -0400, Fernando Soto wrote:
>> Hi Eric,
>>
>> Unfortunately the issue is still reproducible after the patch was
>> applied. Iperf tests were running for almost 24h when it happened:
>
> Well, 3.5 is not a stable kernel, did you try a recent version ?
>
>
