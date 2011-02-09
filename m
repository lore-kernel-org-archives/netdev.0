From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: manual merge of the net tree with the net-current
 tree
Date: Tue, 08 Feb 2011 17:06:47 -0800 (PST)
Message-ID: <20110208.170647.116377212.davem@davemloft.net>
References: <20110209115609.79932942.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, jesse.brandeburg@intel.com,
	jeffrey.t.kirsher@intel.com, bruce.w.allan@intel.com
To: sfr@canb.auug.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110209115609.79932942.sfr@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 9 Feb 2011 11:56:09 +1100

> Today's linux-next merge of the net tree got a conflict in
> drivers/net/e1000e/netdev.c between commit
> 463342741222c79469303cdab8ce99c8bc2d80e8 ("e1000e: tx_timeout should not
> increment for non-hang events") from the net-current tree and commit
> 90da06692532541a38f9857972e1fd6b1cdfb45a ("e1000e: reduce scope of some
> variables, remove unnecessary ones") from the net tree.
> 
> I fixed it up (see below) and can carry the fix as necessary.

I'll do a merge to clear this up, thanks Stephen.
