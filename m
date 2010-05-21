From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the suspend tree
Date: Thu, 20 May 2010 22:46:44 -0700 (PDT)
Message-ID: <20100520.224644.21290162.davem@davemloft.net>
References: <20100507130821.3fb72c9d.sfr@canb.auug.org.au>
	<201005080413.24465.rjw@sisk.pl>
	<20100521102913.ae4e8cd2.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, torvalds@linux-foundation.org, rjw@sisk.pl,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Helmut.Schaa@gmx.de, netdev@vger.kernel.org
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100521102913.ae4e8cd2.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Fri, 21 May 2010 10:29:13 +1000

> On Sat, 8 May 2010 04:13:24 +0200 "Rafael J. Wysocki" <rjw@sisk.pl> wrote:
>>
>> On Friday 07 May 2010, Stephen Rothwell wrote:
>> Both trees are based on Linus' current and I don't see a good way of fixing
>> this issue in any of them individually.
> 
> The suspend tree has been merged into Linus' tree, so this patch is
> needed in the net tree before it is merged (or as part of the merge).

Since the net tree is still on it's way to Linus, we'll just have to
wait for him to do that merge.

Then we can sort this out.  I don't want to touch a tree that is
already on it's way.

Thanks Stephen.
