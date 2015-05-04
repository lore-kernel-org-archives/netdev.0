From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Revert "smc91x: retrieve IRQ and trigger flags in a
 modern way"
Date: Mon, 04 May 2015 15:13:13 -0400 (EDT)
Message-ID: <20150504.151313.1067947846072895736.davem@davemloft.net>
References: <878uew8xfe.fsf@free.fr>
	<20150317.150520.62518083516614772.davem@redhat.com>
	<CACRpkdYYvUYygEjdHOT==W0CtMpyUbVYJxuFzNfL8mFOqHBxcw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robert.jarzmik@free.fr, nico@fluxnic.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linus.walleij@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38244 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751078AbbEDTNQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 15:13:16 -0400
In-Reply-To: <CACRpkdYYvUYygEjdHOT==W0CtMpyUbVYJxuFzNfL8mFOqHBxcw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Walleij <linus.walleij@linaro.org>
Date: Mon, 4 May 2015 15:18:39 +0200

> On Tue, Mar 17, 2015 at 8:05 PM, David Miller <davem@redhat.com> wrote:
>> From: Robert Jarzmik <robert.jarzmik@free.fr>
>> Date: Mon, 16 Mar 2015 22:06:13 +0100
>>
>>> David Miller <davem@davemloft.net> writes:
>>>
>>>> From: Robert Jarzmik <robert.jarzmik@free.fr>
>>>> Date: Thu, 19 Feb 2015 21:48:49 +0100
>>>>
>>>>> Linus has submitted the patch [1]. I'll be watching carefully until -rc4 that
>>>>> this is applied. If it's not, I'll reping you to apply this revert. Until then,
>>>>> you can forget about it, I'll do the follow-up.
>>>>>
>>>>> Does that plan sound good to you ?
>>>>
>>>> It sounds good to me.
>>>
>>> Hi David,
>>>
>>> Unfortunately Linus's patch didn't make it upstream. Therefore I'll ask you to
>>> apply the revert, which is reminded in [1].
>>
>> Revert applied, thanks.
> 
> Since the required patch fixing the actual problem is now upstream,
> can we revert the revert?

Ok, done.
