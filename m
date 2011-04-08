From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: manual merge of the net tree with Linus' tree
Date: Thu, 07 Apr 2011 20:49:09 -0700 (PDT)
Message-ID: <20110407.204909.115926267.davem@davemloft.net>
References: <20110408134551.521c6606.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, lucas.demarchi@profusion.mobi,
	joe@perches.com
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20110408134551.521c6606.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Fri, 8 Apr 2011 13:45:51 +1000

> Today's linux-next merge of the net tree got a conflict in
> drivers/net/smsc911x.c between commit 25985edcedea ("Fix common
> misspellings") from Linus' tree and commit dffc6b2432ea ("smsc911x: Use
> pr_fmt, netdev_<level>, and netif_<level>") from the net tree.
> 
> I fixedd it up (see below) anc can carry the fix as necessary.

Thanks Stephen, I'll clear this one up some time in the next week.
