From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: manual merge of the net-next tree with the net tree
Date: Tue, 30 Apr 2013 04:03:20 -0400 (EDT)
Message-ID: <20130430.040320.8958281566721040.davem@davemloft.net>
References: <20130426132701.ab5ef20e111d529c2c0ae71d@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, ajit.khaparde@emulex.com,
	vasundhara.volam@emulex.com, sathya.perla@emulex.com
To: sfr@canb.auug.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130426132701.ab5ef20e111d529c2c0ae71d@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Fri, 26 Apr 2013 13:27:01 +1000

> Today's linux-next merge of the net-next tree got a conflict in
> drivers/net/ethernet/emulex/benet/be.h between commit bc0c3405abbb
> ("be2net: fix a Tx stall bug caused by a specific ipv6 packet") from the
> net tree and commit 0ad3157e813a ("be2net: Avoid flashing BE3 UFI on
> BE3-R chip") from the net-next tree.
> 
> I fixed it up (see below) and can carry the fix as necessary (no action
> is required).

I fixed it up identically when I merged net into net-next, thanks!
