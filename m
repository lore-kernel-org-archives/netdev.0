From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: linux-next: manual merge of the infiniband tree with Linus' tree
Date: Tue, 26 Feb 2013 09:27:06 +0200
Message-ID: <512C63CA.3050004@mellanox.com>
References: <20130226114508.0f8d1101156f9f4a309579f6@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <roland@kernel.org>, <linux-rdma@vger.kernel.org>,
	<linux-next@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Hadar Hen Zion <hadarh@mellanox.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Shani Michaeli <shanim@mellanox.com>,
	Haggai Eran <haggaie@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130226114508.0f8d1101156f9f4a309579f6@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 26/02/2013 02:45, Stephen Rothwell wrote:
> Hi all,
>
> Today's linux-next merge of the infiniband tree got a conflict in
> drivers/net/ethernet/mellanox/mlx4/mlx4.h between commit 23537b732f5d
> ("net/mlx4_core: Use firmware driven flow steering hash mode") from
> Linus' tree and commit e448834e3545 ("mlx4_core: Enable memory windows in
> {INIT, QUERY}_HCA") from the infiniband tree.
>
> I fixed it up (see below) and can carry the fix as necessary (no action
> is required).
>

thanks,

Acked-by: Or Gerlitz <ogerlitz@mellanox.com>
