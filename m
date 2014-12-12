From: Yegor Yefremov <yegorslists@googlemail.com>
Subject: Re: am335x: cpsw: interrupt failure
Date: Fri, 12 Dec 2014 20:19:21 +0100
Message-ID: <CAGm1_kuYrGsfjRO6TVr554yS8dcD4_Z9-j9KL0xpD=X+31OkXQ@mail.gmail.com>
References: <CAGm1_ksPkFXV_S6541cK1TQb_eRTHbspZy4zWxY5GMrrjGD2tA@mail.gmail.com>
 <20141204165609.GJ18045@saruman> <CAGm1_ksNuO75QfgaDUpOe525xDkPhby-z8T=MX3DHdB-LVcR8g@mail.gmail.com>
 <20141210171724.GI4602@saruman> <CAGm1_ksziwSjQnV1rDYsAv2QQCvhnZPOimowmsW5Cib7C01aqA@mail.gmail.com>
 <20141210210234.GN4602@saruman> <CAGm1_ktYg4iDgK7jyi5etSVup61LdookkV+SaQZOpLb6M=y7hA@mail.gmail.com>
 <CAGm1_kuaqXrU4zhNUZeY85+OeXHApSUDjJdsXcyBdvHTNhLCmQ@mail.gmail.com> <20141212173210.GI7549@saruman>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"N, Mugunthan V" <mugunthanvnm@ti.com>
To: Felipe Balbi <balbi@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:54278 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933644AbaLLTTm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2014 14:19:42 -0500
Received: by mail-pa0-f52.google.com with SMTP id eu11so7722946pac.25
        for <netdev@vger.kernel.org>; Fri, 12 Dec 2014 11:19:42 -0800 (PST)
In-Reply-To: <20141212173210.GI7549@saruman>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 12, 2014 at 6:32 PM, Felipe Balbi <balbi@ti.com> wrote:
> Hi,
>
> On Fri, Dec 12, 2014 at 01:00:51PM +0100, Yegor Yefremov wrote:
>> U-Boot version: 2014.07
>> Kernel config is omap2plus with enabled USB
>>
>> # cat /proc/version
>> Linux version 3.18.0 (user@user-VirtualBox) (gcc version 4.8.3
>> 20140320 (prerelease) (Sourcery CodeBench Lite 2014.05-29) ) #6 SMP
>> Mon Dec 8 22:47:43 CET 2014
>
> Wasn't GCC 4.8.x total crap for building ARM kernels ? IIRC it was even
> blacklisted. Can you try with 4.9.x just to make sure ?

Will do.

> I'll try to run your test case here once i'm back from vacations.

Wish you good vacation!

Yegor
