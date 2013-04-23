From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: manual merge of the net-next tree with Linus' tree
Date: Mon, 22 Apr 2013 20:41:34 -0400 (EDT)
Message-ID: <20130422.204134.24585943335801567.davem@davemloft.net>
References: <20130422124334.92adfce6bdbcba7b08fe83a2@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, ivecera@redhat.com, kaber@trash.net
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20130422124334.92adfce6bdbcba7b08fe83a2@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 22 Apr 2013 12:43:34 +1000

> Today's linux-next merge of the net-next tree got a conflict in
> drivers/net/ethernet/emulex/benet/be_main.c between commit f11a869d4e38
> ("be2net: take care of __vlan_put_tag return value") from Linus' tree and
> commit 86a9bad3ab6b ("net: vlan: add protocol argument to packet tagging
> functions") from the net-next tree.
> 
> I fixed it up (see below) and can carry the fix as necessary (no action
> is required).

I took care of this during the net --> net-next merge, thanks!
