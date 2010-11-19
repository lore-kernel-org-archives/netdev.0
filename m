From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: manual merge of the net tree with the net-current
 tree
Date: Fri, 19 Nov 2010 13:11:02 -0800 (PST)
Message-ID: <20101119.131102.229744328.davem@davemloft.net>
References: <20101119111703.8e33c5fb.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, tgraf@infradead.org
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20101119111703.8e33c5fb.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Fri, 19 Nov 2010 11:17:03 +1100

> Hi all,
> 
> Today's linux-next merge of the net tree got a conflict in
> net/ipv6/addrconf.c between commit
> 18a31e1e282f9ed563b131526a88162ccbe04ee3 ("ipv6: Expose reachable and
> retrans timer values as msecs") from the net-current tree and commit
> b382b191ea9e9ccefc437433d23befe91f4a8925 ("ipv6: AF_INET6 link address
> family") from the net tree.
> 
> I fixed it up (I think - see below) and can carry the fix as necessary.

Thanks Stephen, looks complete correct, and I'm thus merging this
exactly like you did as I merge net-2.6 into net-next-2.6 right now.
