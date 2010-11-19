From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: manual merge of the net tree with the net-current
 tree
Date: Fri, 19 Nov 2010 13:14:43 -0800 (PST)
Message-ID: <20101119.131443.35039425.davem@davemloft.net>
References: <20101119111706.d68efe13.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, eric.dumazet@gmail.com
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20101119111706.d68efe13.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Fri, 19 Nov 2010 11:17:06 +1100

> Hi all,
> 
> Today's linux-next merge of the net tree got a conflict in
> drivers/net/bonding/bond_main.c between commit
> 3006bc38895895f1a0352c2e17e1a503f35f7e2f ("bonding: fix a race in IGMP
> handling") from the net-current tree and commit
> 866f3b25a2eb60d7529c227a0ecd80c3aba443fd ("bonding: IGMP handling
> cleanup") from the net tree.
> 
> I just assumed that the latter is a better solution and used that.

Yep, that's correct, and I'm doing the same as I merge things myself
right now.

Thanks!
