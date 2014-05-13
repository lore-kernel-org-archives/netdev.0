From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: manual merge of the net-next tree with the ipsec
 tree
Date: Tue, 13 May 2014 00:07:53 -0400 (EDT)
Message-ID: <20140513.000753.538591395030698596.davem@davemloft.net>
References: <20140513135322.3dfadb7c@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	xiyou.wangcong@gmail.com
To: sfr@canb.auug.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140513135322.3dfadb7c@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Tue, 13 May 2014 13:53:22 +1000

> Today's linux-next merge of the net-next tree got a conflict in
> net/ipv6/xfrm6_output.c between commit 5596732fa8c1 ("xfrm: Fix crash
> with ipv6 IPsec tunnel and NAT") from the ipsec tree and commit
> 60ff746739bf ("net: rename local_df to ignore_df") from the net-next
> tree.
> 
> I fixed it up (see below) and can carry the fix as necessary (no action
> is required).

Looks good to me, thanks Stephen.
