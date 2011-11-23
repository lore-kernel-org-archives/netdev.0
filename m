From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: manual merge of the net-next tree with the net tree
Date: Tue, 22 Nov 2011 19:23:56 -0500 (EST)
Message-ID: <20111122.192356.1964321544725536133.davem@davemloft.net>
References: <20111123111751.60b1e8ba032f6077fa03ca13@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, maze@google.com, adobriyan@gmail.com
To: sfr@canb.auug.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111123111751.60b1e8ba032f6077fa03ca13@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 23 Nov 2011 11:17:51 +1100

> Hi all,
> 
> Today's linux-next merge of the net-next tree got a conflict in
> net/ipv4/inet_diag.c between commit 717b6d836646 ("net-netlink: fix diag
> to export IPv4 tos for dual-stack IPv6 sockets") from the net tree and
> commit 4e3fd7a06dc2 ("net: remove ipv6_addr_copy()") from the net-next
> tree.
> 
> Just context changes.  I fixed it up (see below) can can carry the fix as
> necessary,

Yep, I anticipated this one too, thanks Stephen.
