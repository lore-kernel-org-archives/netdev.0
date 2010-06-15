From: Cong Wang <amwang@redhat.com>
Subject: Re: [0/8] netpoll/bridge fixes
Date: Tue, 15 Jun 2010 18:17:52 +0800
Message-ID: <4C175350.7090309@redhat.com>
References: <20100610124047.GA16658@gondor.apana.org.au> <20100610074912.1303e3da@nehalam> <20100610215643.GA22048@gondor.apana.org.au> <20100610145915.721a86b7@nehalam> <20100610224839.GA22469@gondor.apana.org.au> <20100611021142.GA24490@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Qianfeng Zhang <frzhang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Matt Mackall <mpm@selenic.com>
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58085 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754114Ab0FOKOJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jun 2010 06:14:09 -0400
In-Reply-To: <20100611021142.GA24490@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/11/10 10:11, Herbert Xu wrote:
> On Fri, Jun 11, 2010 at 08:48:39AM +1000, Herbert Xu wrote:
>> On Thu, Jun 10, 2010 at 02:59:15PM -0700, Stephen Hemminger wrote:
>>>
>>> Okay, then add a comment where in_irq is used?
>>
>> Actually let me put it into a wrapper.  I'll respin the patches.
>
> OK here is a repost.  And this time it really is 8 patches :)
> I've tested it lightly.
>

(Sorry for the delay, I was on vacation.)

Thanks much for your nice work!

Patch 1-7 look great for me, so,

Reviewed-by: WANG Cong <amwang@redhat.com>

I don't quite understand patch 8, will reply to it separately.

Thank you.

