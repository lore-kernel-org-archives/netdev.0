From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tilepro ethernet driver: fix a few minor issues
Date: Tue, 03 Apr 2012 18:40:04 -0400 (EDT)
Message-ID: <20120403.184004.2056266545823149252.davem@davemloft.net>
References: <201203302325.q2UNPm8j012403@farm-0012.internal.tilera.com>
	<20120403.182335.782073108961783777.davem@davemloft.net>
	<20120404083738.0b0f09ffc1f8c5a105c240eb@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cmetcalf@tilera.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: sfr@canb.auug.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120404083738.0b0f09ffc1f8c5a105c240eb@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 4 Apr 2012 08:37:38 +1000

> Hi Dave,
> 
> On Tue, 03 Apr 2012 18:23:35 -0400 (EDT) David Miller <davem@davemloft.net> wrote:
>>
>> Format the comment:
>> 
>> 	/* Like
>> 	 * this.
>> 	 */
>> 
>> not:
>> 
>> 	/*
>> 	 * Like
>> 	 * this.
>> 	 */
> 
> People may be confused because Documentation/CodingStyle says to use the
> latter ...

I refuse to be dragged into this conversation, I'm completely aware
of the exact situation and I've stated my peace on this time and time
again.
