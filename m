From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: manual merge of the net tree with the net-current
 tree
Date: Thu, 07 Apr 2011 13:48:21 -0700 (PDT)
Message-ID: <20110407.134821.71129934.davem@davemloft.net>
References: <20110407113943.2f054e2f.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, sathya.perla@emulex.com,
	ajit.khaparde@emulex.com
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20110407113943.2f054e2f.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Thu, 7 Apr 2011 11:39:43 +1000

> Hi all,
> 
> Today's linux-next merge of the net tree got a conflict in
> drivers/net/benet/be_main.c between commit 2d5d41546504 ("be2net: Fix a
> potential crash during shutdown.") from the net-current tree and commit
> 0f4a68288217 ("be2net: cancel be_worker in be_shutdown() even when i/f is
> down") from the net tree.
> 
> I fixed it up (see below) and can carry the fix as necessary.

I'll do a merge to clear this up for you, thanks Stephen.
