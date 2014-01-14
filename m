From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: manual merge of the tip tree with the net-next tree
Date: Mon, 13 Jan 2014 21:48:41 -0800 (PST)
Message-ID: <20140113.214841.1954373583033654604.davem@davemloft.net>
References: <52D4C25F.8060804@zytor.com>
	<20140113.211946.205101073261467184.davem@davemloft.net>
	<20140114164420.d296fbcc4be3a5f126c86069@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hpa@zytor.com, tglx@linutronix.de, mingo@kernel.org,
	peterz@infradead.org, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20140114164420.d296fbcc4be3a5f126c86069@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Tue, 14 Jan 2014 16:44:20 +1100

> On Mon, 13 Jan 2014 21:19:46 -0800 (PST) David Miller <davem@davemloft.net> wrote:
>>
>> From: "H. Peter Anvin" <hpa@zytor.com>
>> Date: Mon, 13 Jan 2014 20:51:43 -0800
>> 
>> > Is there a sensible way we can fix this in either net-next or tip?
>> 
>> I think if I sort the files in net-next the problem will go away,
>> if someone can confirm this I'll do it.
> 
> I have attached 2 patches: one for net-next and one for tip/auto-latest
> (but should be applicable in the appropriate topic branch).  If both are
> applied to their respect trees, then I get no conflict when merging the
> two trees.

Net patch applied, thanks Stephen.
