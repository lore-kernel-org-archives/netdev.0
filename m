From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/4] kthread: NUMA aware kthread_create_on_cpu()
Date: Mon, 29 Nov 2010 09:39:42 -0800 (PST)
Message-ID: <20101129.093942.104054089.davem@davemloft.net>
References: <20101129090510.GA15763@basil.fritz.box>
	<1291023532.3435.29.camel@edumazet-laptop>
	<1291043604.3435.969.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	netdev@vger.kernel.org, tj@kernel.org, rusty@rustcorp.com.au,
	tony.luck@intel.com, fenghua.yu@intel.com
To: eric.dumazet@gmail.com
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <1291043604.3435.969.camel@edumazet-laptop>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 29 Nov 2010 16:13:23 +0100

> Note : compiled and tested on x86_32 and x86_64 only, but these patches
> take care of other arches as well.
> 
> Cc: linux-arch@vger.kernel.org 
> 
> Thanks for your feedback Andi !

I'm fine with these changes:

Acked-by: David S. Miller <davem@davemloft.net>

Since the majority is non-networking it is pretty clear
that someone other than me should integrate these patches.
:-)
