From: Hadar Hen Zion <hadarh@mellanox.com>
Subject: Re: linux-next: manual merge of the net-next tree with the infiniband
 tree
Date: Thu, 12 Jul 2012 15:57:50 +0300
Message-ID: <4FFEC9CE.3000306@mellanox.com>
References: <20120712121307.a482863a98848e3813690ef2@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-next@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Hadar Hen Zion <hadarh@mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Roland Dreier <roland@kernel.org>, <linux-rdma@vger.kernel.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20120712121307.a482863a98848e3813690ef2@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/12/2012 5:13 AM, Stephen Rothwell wrote:
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
>

Thanks Stephen.

Please add:
Acked-by: Hadar Hen Zion <hadarh@mellanox.co.il>

Hadar
