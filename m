From: Robert Jarzmik <robert.jarzmik@free.fr>
Subject: Re: [PATCH] Revert "smc91x: retrieve IRQ and trigger flags in a modern way"
Date: Thu, 19 Feb 2015 21:48:49 +0100
Message-ID: <87egpl8w5q.fsf@free.fr>
References: <1423760350-20149-1-git-send-email-robert.jarzmik@free.fr>
	<CACRpkdZGze_2=hWe414Eum_9hpNXgog5vmu6Y4R_zhg0x2z0SQ@mail.gmail.com>
	<87bnkx6bja.fsf@free.fr>
	<20150219.152841.891912250243016754.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linus.walleij@linaro.org, nico@fluxnic.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150219.152841.891912250243016754.davem@davemloft.net> (David
	Miller's message of "Thu, 19 Feb 2015 15:28:41 -0500 (EST)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

>> Now if you can make it in -rc2 or -rc3, this revert should be forgotten. But if
>> you can't make it for 3.20, I'll push for the revert.
>> 
>> So I think it's up to you now, and let's see what Gregh says about it.
>
> What is the current status of this?  I'd like to see this move forward so we
> can get this fixed ASAP.
Hi David,

Linus has submitted the patch [1]. I'll be watching carefully until -rc4 that
this is applied. If it's not, I'll reping you to apply this revert. Until then,
you can forget about it, I'll do the follow-up.

Does that plan sound good to you ?

Cheers.

-- 
Robert

[1] https://lkml.org/lkml/2015/2/18/310
