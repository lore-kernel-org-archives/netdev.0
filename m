From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: manual merge of the tip tree with the net-next tree
Date: Mon, 13 Jan 2014 21:19:46 -0800 (PST)
Message-ID: <20140113.211946.205101073261467184.davem@davemloft.net>
References: <20140113142059.f9f1c58c391b2c8bbd05699f@canb.auug.org.au>
	<20140114140214.7279bcaf88d7a4514d889186@canb.auug.org.au>
	<52D4C25F.8060804@zytor.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, tglx@linutronix.de, mingo@kernel.org,
	peterz@infradead.org, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: hpa@zytor.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <52D4C25F.8060804@zytor.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "H. Peter Anvin" <hpa@zytor.com>
Date: Mon, 13 Jan 2014 20:51:43 -0800

> Is there a sensible way we can fix this in either net-next or tip?

I think if I sort the files in net-next the problem will go away,
if someone can confirm this I'll do it.
