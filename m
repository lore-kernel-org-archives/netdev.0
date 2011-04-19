From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: manual merge of the net tree with the net-current
 tree
Date: Tue, 19 Apr 2011 00:41:08 -0700 (PDT)
Message-ID: <20110419.004108.246512359.davem@davemloft.net>
References: <20110419131618.a474326a.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, yanivr@broadcom.com,
	shemminger@vyatta.com
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20110419131618.a474326a.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Tue, 19 Apr 2011 13:16:18 +1000

> Today's linux-next merge of the net tree got a conflict in
> drivers/net/bnx2x/bnx2x_ethtool.c between commit 70dda99c41fc ("bnx2x:
> Fix port identification problem") from the net-current tree and commit
> 32d3613475d8 ("bnx2x: convert to set_phys_id") from the net tree.
> 
> I fixed it up (maybe - see below) and can carry the fix as necessary.

Your conflict resolution was pretty much perfect :-)

I've merged net-2.6 into net-next-2.6 to fix this up.

Thanks!
