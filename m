From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/packet: remove dead code and unneeded variable
 from prb_setup_retire_blk_timer()
Date: Mon, 14 Nov 2011 18:47:36 -0500 (EST)
Message-ID: <20111114.184736.1515821968538974735.davem@davemloft.net>
References: <alpine.LNX.2.00.1111150034120.9919@swampdragon.chaosbits.net>
	<20111114.184325.1962580278359413683.davem@davemloft.net>
	<alpine.LNX.2.00.1111150049500.9919@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rmallon@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, eric.dumazet@gmail.com,
	xiaosuo@gmail.com, greearb@candelatech.com, loke.chetan@gmail.com,
	waltje@uWalt.NL.Mugnet.ORG, gw4pts@gw4pts.ampr.org,
	waltje@linux.com, ross.biro@gmail.com, alan@linux.intel.com
To: jj@chaosbits.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1111150049500.9919@swampdragon.chaosbits.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesper Juhl <jj@chaosbits.net>
Date: Tue, 15 Nov 2011 00:51:57 +0100 (CET)

> On Mon, 14 Nov 2011, David Miller wrote:
> 
>> From: Jesper Juhl <jj@chaosbits.net>
>> Date: Tue, 15 Nov 2011 00:37:33 +0100 (CET)
>> 
>> > David: You may want to pass on this one. I obviously didn't think it 
>> > through properly - sorry :-(
>> 
>> It's already in my tree and pushed out to kernel.org, what in the
>> world do you think "applied" means?
>> 
> I'm sorry about that. I try to be careful with my patches, but sometimes 
> mistakes slip through - I'm only human... I do my best, but I mess up 
> sometimes and Ryan raised a good point that I had not considered when I 
> prepared the patch - what would you have me do except reply to his mail as 
> I did?

Send a patch to fix things back up.
