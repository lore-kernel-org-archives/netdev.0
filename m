From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: manual merge of the net-next tree with the net tree
Date: Sat, 24 May 2014 00:50:33 -0400 (EDT)
Message-ID: <20140524.005033.220770104598902823.davem@davemloft.net>
References: <20140523134602.4dac2f7c@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, vyasevic@redhat.com,
	vfalico@gmail.com
To: sfr@canb.auug.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140523134602.4dac2f7c@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Fri, 23 May 2014 13:46:02 +1000

> Today's linux-next merge of the net-next tree got a conflict in
> drivers/net/bonding/bond_alb.c between commit d0c21d43a5a1 ("bonding:
> Send ALB learning packets using the right source") from the net tree
> and commit 8557cd74ca8a ("bonding: replace SLAVE_IS_OK() with
> bond_slave_can_tx()") from the net-next tree.
> 
> I fixed it up (see below) and can carry the fix as necessary (no action
> is required).

Thanks Stephen, I just merged net into net-next and this conflict
should therefore be gone.
