From: Maxime Coquelin <mcoquelin.stm32-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RESEND PATCH v6 0/6] Add Ethernet support on STM32F429
Date: Tue, 17 May 2016 11:20:16 +0200
Message-ID: <CALszF6Cfs02-tGvFqpyJpUy7jSfjGTY8fVaaLQ8iQaGfCxvDtQ@mail.gmail.com>
References: <1462789899-13153-1-git-send-email-alexandre.torgue@gmail.com>
	<20160509.150634.213732321950308841.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexandre Torgue <alexandre.torgue-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Joachim Eastwood <manabian-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160509.150634.213732321950308841.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi David,

2016-05-09 21:06 GMT+02:00 David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>:
> From: Alexandre TORGUE <alexandre.torgue-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Date: Mon,  9 May 2016 12:31:33 +0200
>
>> STM32F429 Chip embeds a Synopsys 3.50a MAC IP.
>> This series:
>>  -enhance current stmmac driver to control it (code already
>> available) and adds basic glue for STM32F429 chip.
>>  -Enable basic Net config in kernel.
>
> I assume this will go via the ARM tree, for the networking bits:
I would expect patches 1, 2 & 3 to got via your tree, to avoid conflicts.

> Acked-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

Thanks,
Maxime
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
