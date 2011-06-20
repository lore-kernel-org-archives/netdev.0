From: Vitaliy Ivanov <vitalivanov@gmail.com>
Subject: Re: [PATCH][Trivial]: ipv4, ping: Remove duplicate icmp.h include
Date: Mon, 20 Jun 2011 23:50:38 +0300
Message-ID: <415E440A-6C7F-4ADB-AE81-05AEAD5C3269@gmail.com>
References: <alpine.LNX.2.00.1106201028340.18991@swampdragon.chaosbits.net> <20110620.130515.1956879930278498236.davem@davemloft.net>
Mime-Version: 1.0 (iPhone Mail 7A341)
Content-Type: text/plain;
	charset=us-ascii;
	format=flowed;
	delsp=yes
Content-Transfer-Encoding: 7bit
Cc: "jj@chaosbits.net" <jj@chaosbits.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"segoon@openwall.com" <segoon@openwall.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"trivial@kernel.org" <trivial@kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110620.130515.1956879930278498236.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David,

It's already in Jiri's trivial tree.

Vitaliy

Sent from my iPhone

On Jun 20, 2011, at 23:05, David Miller <davem@davemloft.net> wrote:

> From: Jesper Juhl <jj@chaosbits.net>
> Date: Mon, 20 Jun 2011 10:31:20 +0200 (CEST)
>
>> Remove the duplicate inclusion of net/icmp.h from net/ipv4/ping.c
>>
>> Signed-off-by: Jesper Juhl <jj@chaosbits.net>
>
> Applied.
> --
> To unsubscribe from this list: send the line "unsubscribe linux- 
> kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
