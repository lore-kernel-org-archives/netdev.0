From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [RESEND PATCH v6 0/6] Add Ethernet support on STM32F429
Date: Tue, 17 May 2016 12:25:27 -0400 (EDT)
Message-ID: <20160517.122527.1937360418899371800.davem@davemloft.net>
References: <1462789899-13153-1-git-send-email-alexandre.torgue@gmail.com>
	<20160509.150634.213732321950308841.davem@davemloft.net>
	<CALszF6Cfs02-tGvFqpyJpUy7jSfjGTY8fVaaLQ8iQaGfCxvDtQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexandre.torgue-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, peppe.cavallaro-qxv4g6HH51o@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, manabian-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, wens-jdAy2FN1RRM@public.gmane.org
To: mcoquelin.stm32-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CALszF6Cfs02-tGvFqpyJpUy7jSfjGTY8fVaaLQ8iQaGfCxvDtQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Maxime Coquelin <mcoquelin.stm32-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Tue, 17 May 2016 11:20:16 +0200

> Hi David,
> 
> 2016-05-09 21:06 GMT+02:00 David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>:
>> From: Alexandre TORGUE <alexandre.torgue-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> Date: Mon,  9 May 2016 12:31:33 +0200
>>
>>> STM32F429 Chip embeds a Synopsys 3.50a MAC IP.
>>> This series:
>>>  -enhance current stmmac driver to control it (code already
>>> available) and adds basic glue for STM32F429 chip.
>>>  -Enable basic Net config in kernel.
>>
>> I assume this will go via the ARM tree, for the networking bits:
> I would expect patches 1, 2 & 3 to got via your tree, to avoid conflicts.

I don't think putting them all via the ARM tree is going to create much
in the way of conflicts, and right now during the merge window offloading
that work from me would really help my backlog a lot.

Thanks.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
