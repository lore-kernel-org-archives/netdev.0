From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: linux-next: manual merge of the net-next tree with the infiniband
 tree
Date: Tue, 27 Nov 2012 08:43:06 +0200
Message-ID: <50B460FA.1080603@mellanox.com>
References: <20121127114751.6961da02245ed6851190aca2@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-next@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Roland Dreier <roland@kernel.org>,
	<linux-rdma@vger.kernel.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Amir Vadai <amirv@mellanox.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121127114751.6961da02245ed6851190aca2@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 27/11/2012 02:47, Stephen Rothwell wrote:
> Hi all,
>
> Today's linux-next merge of the net-next tree got a conflict in
> drivers/net/ethernet/mellanox/mlx4/en_rx.c between commit 08ff32352d6f
> ("mlx4: 64-byte CQE/EQE support") from the infiniband tree and commit
> f1d29a3fa68b ("mlx4_en: Remove remnants of LRO support") from the
> net-next tree.
>
> I fixed it up (see below) and can carry the fix as necessary (no action
> is required).
>

Acked-by: Or Geritz <ogerlitz@mellanox.com>
