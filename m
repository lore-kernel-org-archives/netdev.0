From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: manual merge of the net tree with Linus' tree
Date: Sun, 26 Dec 2010 18:21:00 -0800 (PST)
Message-ID: <20101226.182100.71128443.davem@davemloft.net>
References: <20101227104144.cedc2d63.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, xiaosuo@gmail.com
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20101227104144.cedc2d63.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 27 Dec 2010 10:41:44 +1100

> Today's linux-next merge of the net tree got a conflict in
> net/ipv4/fib_frontend.c between commit
> e058464990c2ef1f3ecd6b83a154913c3c06f02a ("Revert "ipv4: Allow
> configuring subnets as local addresses"") from Linus' tree and commit
> 5811662b15db018c740c57d037523683fd3e6123 ("net: use the macros defined
> for the members of flowi") from the net tree.
> 
> Just context changes (I think).  I fixed it up (see below) and can carry
> the fix as necessary.

Thanks Stephen, I'll take care of this.
