From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: manual merge of the net-next tree with the net tree
Date: Wed, 10 Dec 2014 14:49:43 -0500 (EST)
Message-ID: <20141210.144943.1497210993149601967.davem@davemloft.net>
References: <20141210122036.133457c9@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Thomas.Lendacky@amd.com,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: sfr@canb.auug.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141210122036.133457c9@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 10 Dec 2014 12:20:36 +1100

> Today's linux-next merge of the net-next tree got a conflict in
> drivers/net/ethernet/amd/xgbe/xgbe-desc.c between commit 03ccc4c0a9da
> ("amd-xgbe: Do not clear interrupt indicator") from the net tree and
> commit c9f140ebb008 ("amd-xgbe: Separate Tx/Rx ring data fields into
> new structs") from the net-next tree.
> 
> I fixed it up (see below) and can carry the fix as necessary (no action
> is required).

As you have seen there are a lot of merge hassles to sort out between
the 'net' and 'net-next' tree right now, probably I just added a few
more :-)

I'll try to do the merge by the end of today so that these headaches
go away for you.

Thanks.
