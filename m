From: Loganaden Velvindron <loganaden@gmail.com>
Subject: Re: IrDA woes..
Date: Sat, 4 Jan 2014 12:15:11 +0400
Message-ID: <CAOp4FwReupPDNbXeOjcD9zsEmJbSN-t6j2WrUhvQ21-HgfjXGw@mail.gmail.com>
References: <CA+55aFz2CQ4B1JSpQ75TuQrrd9sUnhV+u=T2dWZY2NTTT5OmpQ@mail.gmail.com>
	<20140102.034653.1968429090467668489.davem@davemloft.net>
	<CA+55aFz_qDYP_P0PLUNv0wotoy=5PcS+7Qtt=U6EzvL4h4E69A@mail.gmail.com>
	<1388798611.4326.11.camel@zurbaran>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>
To: Samuel Ortiz <samuel@sortiz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f52.google.com ([209.85.216.52]:62373 "EHLO
	mail-qa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750953AbaADIPM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jan 2014 03:15:12 -0500
Received: by mail-qa0-f52.google.com with SMTP id cm18so1271345qab.4
        for <netdev@vger.kernel.org>; Sat, 04 Jan 2014 00:15:11 -0800 (PST)
In-Reply-To: <1388798611.4326.11.camel@zurbaran>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 4, 2014 at 5:23 AM, Samuel Ortiz <samuel@sortiz.org> wrote:
> Hi Linus,
>
> On Thu, 2014-01-02 at 11:11 -0800, Linus Torvalds wrote:
>> The odd thing is that I *have* seen it work, a couple of times, so
>> it's not like it *never* works (in which case I'd just think that the
>> above simply isn't even supposed to work at all), but the "it actually
>> worked" is a very rare occurrence. Most of the time opening the ircomm
>> blocks. But sometimes it works after a few seconds. Very odd.
> I'm pretty sure the stack was never designed nor tested for that kind of
> usage, so I'm even surprised it ever worked for you.
>
>> Samuel is listed as maintainer, but I'm getting the feeling he has
>> long since moved on.
> That's correct, and the MAINTAINERS file should be updated I guess.
> The combination of my last IrDA enabled phone dying and the IrDA
> association removing my access to the specs significantly lowered my
> interest.

May we know what was the reason given to you ?


>
> Cheers,
> Samuel.
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
This message is strictly personal and the opinions expressed do not
represent those of my employers, either past or present.
