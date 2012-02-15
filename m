From: Dongsoo Nathaniel Kim <dongsoo.kim@gmail.com>
Subject: Re: About bnx2-mips-09-6.2.1b.fw (Broadcom ethernet) firmware
Date: Wed, 15 Feb 2012 15:25:09 +0900
Message-ID: <CAP+Vy9cVmfEsp5h2u1iCd589SpLkuRCcgKnRkc05nP-Ni+NZkg@mail.gmail.com>
References: <CAP+Vy9cSK7kWbfYGT566BshozaQ-NqH0UpeuXEErLRLMP9Tt0g@mail.gmail.com>
 <CAHLZz11wU4sKtq6wD_ZFaOH+6QU-JTYgXFV6Vs1qucMa26a0fw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>
To: Harvey Harrison <harvey.harrison@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-tul01m020-f174.google.com ([209.85.214.174]:34022 "EHLO
	mail-tul01m020-f174.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751945Ab2BOGZa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 01:25:30 -0500
Received: by obcva7 with SMTP id va7so1043620obc.19
        for <netdev@vger.kernel.org>; Tue, 14 Feb 2012 22:25:29 -0800 (PST)
In-Reply-To: <CAHLZz11wU4sKtq6wD_ZFaOH+6QU-JTYgXFV6Vs1qucMa26a0fw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Harvey,

So, now user has to include his or her own firmware manually?

I may need a post-it not to forget, cause sometimes I build kernel
from scratch ;-( (then I will have to download firmware again in that
case)



On Wed, Feb 15, 2012 at 2:50 PM, Harvey Harrison
<harvey.harrison@gmail.com> wrote:
> On Tue, Feb 14, 2012 at 9:26 PM, Dongsoo Nathaniel Kim
> <dongsoo.kim@gmail.com> wrote:
>> Hello folks,
>>
>> I'm wondering if it is ok to send a patch which includes
>> bnx2-mips-09-6.2.1b.fw.ihex.
>>
>
> firmware is no longer distributed with kernel source, there is a
> separate firmware repo:
>
> git://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git
>
> Where you'll find the above file is already incuded in the bnx2/ folder
>
> Cheers,
>
> Harvey



-- 
=
Dongsoo Nathaniel Kim
Linux kernel, media device S/W engineer / Ph.D Student
Dept. of Computer Science, KAIST
Real-time & Embedded Systems Lab.
