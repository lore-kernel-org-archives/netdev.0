From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: Re: [PATCH] ipv6: exthdrs: use swap macro in ipv6_dest_hao
Date: Sat, 28 Oct 2017 14:58:45 -0500
Message-ID: <20171028145845.Horde.KXEVJt9tHNL9fGBIztlOp3g@gator4166.hostgator.com>
References: <20171027041002.GA13506@embeddedor.com>
 <20171028.190721.904336719839639001.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed; DelSp=Yes
Cc: kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171028.190721.904336719839639001.davem@redhat.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Quoting David Miller <davem@redhat.com>:

> From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
> Date: Thu, 26 Oct 2017 23:10:35 -0500
>
>> make use of the swap macro and remove unnecessary variable tmp_addr.
>> This makes the code easier to read and maintain.
>>
>> This code was detected with the help of Coccinelle.
>>
>> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
>
> Applied to net-next, thanks.

Glad to help.

Thanks
--
Gustavo A. R. Silva
