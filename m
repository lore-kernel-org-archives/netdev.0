From: Yinglin Sun <yinglin.s@gmail.com>
Subject: Re: moving GIT back to kernel.org...
Date: Sat, 8 Oct 2011 00:09:24 -0700
Message-ID: <CAN17JHUdg2aJmpMOD_hn61eramPPnTr0_tiy3c7w7cKa8FMtsQ@mail.gmail.com>
References: <20111007.145703.842130763413648388.davem@davemloft.net>
	<20111007.155902.916470368193047875.davem@davemloft.net>
	<CAN17JHUGnAbHJmwybjJVdxq4JOgHfDxChw1P7q1yrkqH6Ci05w@mail.gmail.com>
	<4E8FF54F.1080306@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	sfr@canb.auug.org.au, linux-wireless@vger.kernel.org,
	netfilter-devel@vger.kernel.org, sparclinux@vger.kernel.org,
	linux-ide@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:47748 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750827Ab1JHHJ0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Oct 2011 03:09:26 -0400
In-Reply-To: <4E8FF54F.1080306@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 8, 2011 at 12:01 AM, Jeff Kirsher <tarbal@gmail.com> wrote:
> On 10/07/2011 11:55 PM, Yinglin Sun wrote:
>> On Fri, Oct 7, 2011 at 12:59 PM, David Miller <davem@davemloft.net> =
wrote:
>>> From: David Miller <davem@davemloft.net>
>>> Date: Fri, 07 Oct 2011 14:57:03 -0400 (EDT)
>>>
>>>> I'm about to setup my GIT trees on kernel.org, once that is comple=
te
>>>> I will be solely updating those trees again.
>>>>
>>>> I will notify everyone when this is ready to go.
>>>>
>>>> Just a heads up for everyone...
>>> Ok, they are now online, please update your URLs.
>>>
>>> git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git
>>> git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git
>>> git://git.kernel.org/pub/scm/linux/kernel/git/davem/sparc.git
>>> git://git.kernel.org/pub/scm/linux/kernel/git/davem/ide.git
>>>
>> I'm still new to net kernel development, so a little confused about =
these trees.
>> So we should submit patches based on these trees, instead of Linus'?
>> About net and net-next, How to decide which one to use?
>>
>> Thanks!
>>
>> Yinglin
>>
>
> *If* you have change against the network core/drivers then, you would
> want to use David Miller's net or net-next trees.
>
> As a general rule:
> =C2=A0- net tree is only for fixes/critical fixes
> =C2=A0- net-next tree is for everything else
>
> There are always exceptions, but if you stick to the above general ru=
le,
> you will be fine.
>
>

Got it. Thanks Jeff!

Yinglin
