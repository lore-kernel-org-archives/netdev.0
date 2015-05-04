From: Linus Walleij <linus.walleij@linaro.org>
Subject: Re: [PATCH] Revert "smc91x: retrieve IRQ and trigger flags in a
 modern way"
Date: Mon, 4 May 2015 15:18:39 +0200
Message-ID: <CACRpkdYYvUYygEjdHOT==W0CtMpyUbVYJxuFzNfL8mFOqHBxcw@mail.gmail.com>
References: <87egpl8w5q.fsf@free.fr>
	<20150219.162213.557240575455109795.davem@davemloft.net>
	<878uew8xfe.fsf@free.fr>
	<20150317.150520.62518083516614772.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Robert Jarzmik <robert.jarzmik@free.fr>,
	Nicolas Pitre <nico@fluxnic.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Miller <davem@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150317.150520.62518083516614772.davem@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 17, 2015 at 8:05 PM, David Miller <davem@redhat.com> wrote:
> From: Robert Jarzmik <robert.jarzmik@free.fr>
> Date: Mon, 16 Mar 2015 22:06:13 +0100
>
>> David Miller <davem@davemloft.net> writes:
>>
>>> From: Robert Jarzmik <robert.jarzmik@free.fr>
>>> Date: Thu, 19 Feb 2015 21:48:49 +0100
>>>
>>>> Linus has submitted the patch [1]. I'll be watching carefully until -rc4 that
>>>> this is applied. If it's not, I'll reping you to apply this revert. Until then,
>>>> you can forget about it, I'll do the follow-up.
>>>>
>>>> Does that plan sound good to you ?
>>>
>>> It sounds good to me.
>>
>> Hi David,
>>
>> Unfortunately Linus's patch didn't make it upstream. Therefore I'll ask you to
>> apply the revert, which is reminded in [1].
>
> Revert applied, thanks.

Since the required patch fixing the actual problem is now upstream,
can we revert the revert?

Caused by response time in maintainers, so a people problem, not
a technical one, sadly :/

Yours,
Linus Walleij
