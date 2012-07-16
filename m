From: Jack Morgenstein <jackm@dev.mellanox.co.il>
Subject: Re: linux-next: manual merge of the net-next tree with the infiniband tree
Date: Mon, 16 Jul 2012 11:33:16 +0300
Message-ID: <201207161133.16886.jackm@dev.mellanox.co.il>
References: <20120712120950.223be053857381046b7d5db6@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Roland Dreier <roland@kernel.org>, linux-rdma@vger.kernel.org,
	Hadar Hen Zion <hadarh@mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120712120950.223be053857381046b7d5db6@canb.auug.org.au>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 12 July 2012 05:09, Stephen Rothwell wrote:
> Hi all,
> 
> Today's linux-next merge of the net-next tree got a conflict in
> drivers/net/ethernet/mellanox/mlx4/main.c between commit 6634961c14d3
> ("mlx4: Put physical GID and P_Key table sizes in mlx4_phys_caps struct
> and paravirtualize them") from the infiniband tree and commit
> 0ff1fb654bec ("{NET, IB}/mlx4: Add device managed flow steering firmware
> API") from the net-next tree.
> 
> Just context changes (I think).  I have fixed it up (see below) and can
> carry the fix as necessary.

Thanks, Stephen!

Ack for IB side.

-Jack
