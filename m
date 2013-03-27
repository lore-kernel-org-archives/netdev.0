From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: manual merge of the net-next tree with Linus' tree
Date: Wed, 27 Mar 2013 00:54:52 -0400 (EDT)
Message-ID: <20130327.005452.686619573507820021.davem@davemloft.net>
References: <20130327115743.7d6c10f1e1c67f02e9c96ff8@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, pshelar@nicira.com
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20130327115743.7d6c10f1e1c67f02e9c96ff8@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 27 Mar 2013 11:57:43 +1100

> Today's linux-next merge of the net-next tree got a conflict in
> include/net/ipip.h between commit 330305cc4a6b ("pv4: Fix ip-header
> identification for gso packets") from Linus' tree and commit c54419321455
> ("GRE: Refactor GRE tunneling code") from the net-next tree.
> 
> I just dropped the file (as the latter change did) and can carry the fix
> as necessary (no action is required).

Thanks, I'll take care of this when I next merge.
