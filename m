From: Jack Morgenstein <jackm@dev.mellanox.co.il>
Subject: Re: linux-next: manual merge of the net-next tree with the infiniband tree
Date: Mon, 16 Jul 2012 11:34:34 +0300
Message-ID: <201207161134.34574.jackm@dev.mellanox.co.il>
References: <20120712121307.a482863a98848e3813690ef2@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Hadar Hen Zion <hadarh@mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Roland Dreier <roland@kernel.org>, linux-rdma@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20120712121307.a482863a98848e3813690ef2@canb.auug.org.au>
Content-Disposition: inline
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 12 July 2012 05:13, Stephen Rothwell wrote:
> Hi all,
> 
> Today's linux-next merge of the net-next tree got a conflict in
> include/linux/mlx4/device.h between commit 396f2feb05d7 ("mlx4_core:
> Implement mechanism for reserved Q_Keys") from the infiniband tree and
> commit 0ff1fb654bec ("{NET, IB}/mlx4: Add device managed flow steering
> firmware API") from the net-next tree.
> 
> Just context changes.  I fixed it up (see below) and can carry the fix
> as necessary.

Thanks, Stephen!

Your merge looks fine. Ack.

-Jack
