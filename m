From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: manual merge of the net tree with the net-current
 tree
Date: Wed, 06 Oct 2010 19:35:27 -0700 (PDT)
Message-ID: <20101006.193527.116390808.davem@davemloft.net>
References: <20101007123104.bf7a9808.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, eric.dumazet@gmail.com,
	joe@perches.com
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20101007123104.bf7a9808.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Thu, 7 Oct 2010 12:31:04 +1100

> Hi all,
> 
> Today's linux-next merge of the net tree got a conflict in
> net/caif/caif_socket.c between commit
> 79315068f4560f3f7bd6e9790190dcb43059770c ("caif: fix two caif_connect()
> bugs") from the net-current tree and commit
> b31fa5bad576cd8180a5ad70c648333b44320d44 ("net/caif: Use pr_fmt") from
> the net tree.
> 
> I fixed it up (see below) and can carry the fix as necessary.

Thanks Stephen, I'm merging net-2.6 into net-next-2.6 right now
to resolve this.

Thanks!
