From: David Miller <davem@davemloft.net>
Subject: Re: [REGRESSION][PATCH V4 3/3] bpf jit: Let the powerpc jit handle
 negative offsets
Date: Tue, 03 Apr 2012 18:35:10 -0400 (EDT)
Message-ID: <20120403.183510.1401597538063331122.davem@davemloft.net>
References: <4F75D2A5.7060407@googlemail.com>
	<20120403.180302.342779808900865443.davem@davemloft.net>
	<4F7B7A59.2090904@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	eric.dumazet@gmail.com
To: kaffeemonster@googlemail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F7B7A59.2090904@googlemail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Seiffert <kaffeemonster@googlemail.com>
Date: Wed, 4 Apr 2012 00:31:53 +0200

> David Miller schrieb:
> [snip - my patch description]
>> 
>> I'm not applying this until a powerpc person tests it.
>> 
> 
> As Benjamin already said, Matt is having a look, so i expected nothing else.
> 
>> Also, we have an ARM JIT in the tree which probably needs to
>> be fixed similarly.
>> 
> 
> ???
> Oh, in which tree is it?
> I was working against net-next.

It's been in Linus's tree for several days now.

net-next is stale during the merge window and doesn't get updated
until the merge window closes.
