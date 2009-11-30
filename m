From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: manual merge of the net tree with the net-current
 tree
Date: Sun, 29 Nov 2009 17:12:02 -0800 (PST)
Message-ID: <20091129.171202.169130093.davem@davemloft.net>
References: <20091124141131.49b37eec.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, bruce.w.allan@intel.com,
	jeffrey.t.kirsher@intel.com
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20091124141131.49b37eec.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Tue, 24 Nov 2009 14:11:31 +1100

> Hi all,
> 
> Today's linux-next merge of the net tree got a conflict in
> drivers/net/e1000e/phy.c between commit
> 189983d469c6d98e64ddfb9f9ce76725cb082ee5 ("e1000e: remove unnecessary
> 82577 workaround causing link issues") from the net-current tree and
> commit 94d8186a693284344ee5cb9734086c7a2370241a ("e1000e: cleanup ops
> function pointers") from the net tree.
> 
> I fixed it up (see below) and can carry the fix for a while.

This conflict also got dealt with last night when I pulled
net-2.6 into net-next-2.6
