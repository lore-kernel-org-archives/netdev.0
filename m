From: Ido Shamay <idos@dev.mellanox.co.il>
Subject: Re: linux-next: manual merge of the net-next tree with the net tree
Date: Tue, 07 Apr 2015 14:42:14 +0300
Message-ID: <5523C296.9090508@dev.mellanox.co.il>
References: <20150407131819.269e593a@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Ido Shamay <idos@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150407131819.269e593a@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/7/2015 6:18 AM, Stephen Rothwell wrote:
> Hi all,
>
> Today's linux-next merge of the net-next tree got a conflict in
> drivers/net/ethernet/mellanox/mlx4/cmd.c between commit fde913e25496
> ("net/mlx4_core: Fix error message deprecation for ConnectX-2 cards")
> from the net tree and commit a130b5905732 ("net/mlx4: Add SET_PORT
> opcode modifiers enumeration") from the net-next tree.
>
> I fixed it up (see below) and can carry the fix as necessary (no action
> is required).
Looks good, thanks.
