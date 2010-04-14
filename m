From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: manual merge of the net tree with Linus' tree
Date: Tue, 13 Apr 2010 18:47:24 -0700 (PDT)
Message-ID: <20100413.184724.112842393.davem@davemloft.net>
References: <20100414114556.97d7583d.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, ken_kawasaki@spring.nifty.jp,
	jpirko@redhat.com
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100414114556.97d7583d.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 14 Apr 2010 11:45:56 +1000

> Hi all,
> 
> Today's linux-next merge of the net tree got a conflict in
> drivers/net/pcmcia/smc91c92_cs.c between commit
> a6d37024de02e7cb2b2333e438e71355a9c32a0a ("smc91c92_cs: define
> multicast_table as unsigned char") from Linus' tree and commit
> 22bedad3ce112d5ca1eaf043d4990fa2ed698c87 ("net: convert multicast list to
> list_head") from the net tree.
> 
> I fixed it up (see below) and can carry the fix for a while.

Thanks a lot Stephen, I'll merge net-2.6 into net-next-2.6 to
fix this up for you.
