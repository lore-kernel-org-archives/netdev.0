From: David Miller <davem@redhat.com>
Subject: Re: [PATCH] Revert "smc91x: retrieve IRQ and trigger flags in a
 modern way"
Date: Tue, 17 Mar 2015 15:05:20 -0400 (EDT)
Message-ID: <20150317.150520.62518083516614772.davem@redhat.com>
References: <87egpl8w5q.fsf@free.fr>
	<20150219.162213.557240575455109795.davem@davemloft.net>
	<878uew8xfe.fsf@free.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linus.walleij@linaro.org, nico@fluxnic.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: robert.jarzmik@free.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <878uew8xfe.fsf@free.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Robert Jarzmik <robert.jarzmik@free.fr>
Date: Mon, 16 Mar 2015 22:06:13 +0100

> David Miller <davem@davemloft.net> writes:
> 
>> From: Robert Jarzmik <robert.jarzmik@free.fr>
>> Date: Thu, 19 Feb 2015 21:48:49 +0100
>>
>>> Linus has submitted the patch [1]. I'll be watching carefully until -rc4 that
>>> this is applied. If it's not, I'll reping you to apply this revert. Until then,
>>> you can forget about it, I'll do the follow-up.
>>> 
>>> Does that plan sound good to you ?
>>
>> It sounds good to me.
> 
> Hi David,
> 
> Unfortunately Linus's patch didn't make it upstream. Therefore I'll ask you to
> apply the revert, which is reminded in [1].

Revert applied, thanks.
