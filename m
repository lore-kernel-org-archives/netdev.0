From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: Re: [PATCH v2] ipv6: esp6: use BUG_ON instead of if condition
 followed by BUG
Date: Thu, 26 Oct 2017 23:12:51 -0500
Message-ID: <20171026231251.Horde.tzlbG8MZb2ce8i64Q1f4v2a@gator4166.hostgator.com>
References: <20171025040750.GB1999@gondor.apana.org.au>
 <20171026125106.GA13009@embeddedor.com>
 <20171026223836.GB8783@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed; DelSp=Yes
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171026223836.GB8783@gondor.apana.org.au>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Quoting Herbert Xu <herbert@gondor.apana.org.au>:

> On Thu, Oct 26, 2017 at 07:51:06AM -0500, Gustavo A. R. Silva wrote:
>> Use BUG_ON instead of if condition followed by BUG in esp_remove_trailer.
>>
>> This issue was detected with the help of Coccinelle.
>>
>> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
>
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks!

--
Gustavo A. R. Silva
