From: Linus Walleij <linus.walleij@linaro.org>
Subject: Re: [PATCH] Revert "smc91x: retrieve IRQ and trigger flags in a
 modern way"
Date: Mon, 23 Feb 2015 16:14:51 +0100
Message-ID: <CACRpkdaEtx2C3ifCwUXmXFheSbkQb6mHUoi_gQLHTjO1peZMpA@mail.gmail.com>
References: <1423760350-20149-1-git-send-email-robert.jarzmik@free.fr>
	<CACRpkdZGze_2=hWe414Eum_9hpNXgog5vmu6Y4R_zhg0x2z0SQ@mail.gmail.com>
	<87bnkx6bja.fsf@free.fr>
	<20150219.152841.891912250243016754.davem@davemloft.net>
	<87egpl8w5q.fsf@free.fr>
	<CACRpkdZf4ceexYP8eNTcetbRoZ6RUoZjyh60CF4MK+w6gjUH+g@mail.gmail.com>
	<20150220153329.GA18111@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Robert Jarzmik <robert.jarzmik@free.fr>,
	Grant Likely <grant.likely@linaro.org>,
	David Miller <davem@davemloft.net>,
	Nicolas Pitre <nico@fluxnic.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150220153329.GA18111@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 20, 2015 at 4:33 PM, Greg KH <gregkh@linuxfoundation.org> wrote:
> On Fri, Feb 20, 2015 at 10:37:59AM +0100, Linus Walleij wrote:
>> On Thu, Feb 19, 2015 at 9:48 PM, Robert Jarzmik <robert.jarzmik@free.fr> wrote:
>> > David Miller <davem@davemloft.net> writes:
>> >
>> >>> Now if you can make it in -rc2 or -rc3, this revert should be forgotten. But if
>> >>> you can't make it for 3.20, I'll push for the revert.
>> >>>
>> >>> So I think it's up to you now, and let's see what Gregh says about it.
>> >>
>> >> What is the current status of this?  I'd like to see this move forward so we
>> >> can get this fixed ASAP.
>> > Hi David,
>> >
>> > Linus has submitted the patch [1]. I'll be watching carefully until -rc4 that
>> > this is applied. If it's not, I'll reping you to apply this revert. Until then,
>> > you can forget about it, I'll do the follow-up.
>> > [1] https://lkml.org/lkml/2015/2/18/310
>>
>> Looping in Greg and Grant so they know we are waiting for their verdict
>> on that patch...
>
> I have no idea what you are talking about here :(

It is a patch to drivers/base, which I'm waiting for you to look at...
The link to the patch was right above, here it is again :)

https://lkml.org/lkml/2015/2/18/310

Yours,
Linus Walleij
