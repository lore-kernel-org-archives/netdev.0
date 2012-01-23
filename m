From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH/RESEND] drivers/net/ethernet: dev_alloc_skb to
 netdev_alloc_skb
Date: Mon, 23 Jan 2012 14:23:55 -0500 (EST)
Message-ID: <20120123.142355.405932925189446350.davem@davemloft.net>
References: <1327344034.6317.3.camel@joe2Laptop>
	<20120123.135350.756110788533975068.davem@davemloft.net>
	<CA+Dx6HYga9HkwzZNCXc7-q7JvV5PJ2w-QqT4p1zb+upWfn3+Ag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, netdev@vger.kernel.org, hch@lst.de,
	linux-kernel@vger.kernel.org, eric.dumazet@gmail.com
To: netdev@pradeepdalvi.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+Dx6HYga9HkwzZNCXc7-q7JvV5PJ2w-QqT4p1zb+upWfn3+Ag@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Pradeep A. Dalvi" <netdev@pradeepdalvi.com>
Date: Tue, 24 Jan 2012 00:43:10 +0530

> On Tue, Jan 24, 2012 at 12:23 AM, David Miller <davem@davemloft.net> wrote:
>> From: Joe Perches <joe@perches.com>
>> Date: Mon, 23 Jan 2012 10:40:34 -0800
>>
>>> Perhaps you should break this large patch
>>> into multiple separate patches.
>>
>> Agreed, this patch is way too large especially for what is obviously
>> turning out to be a very non-trivial transformation in some cases
>> and also new patch submitters should generally avoid large patches
>> like this.
> 
> Acked! Will try to separate out trivial & non-trivial changes.
> Although, still trivial changes would be big enough. And at the same
> time, splitting changes into 118 patches might turn out to be
> cumbersome for review.

We didn't say to create 118 patches, we're talking about on the
order of 4 or 5 patches.
