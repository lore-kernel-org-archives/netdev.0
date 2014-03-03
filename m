From: David Miller <davem@davemloft.net>
Subject: Re: [nf-next PATCH V2 0/5] netfilter: conntrack: optimization,
 remove central spinlock
Date: Sun, 02 Mar 2014 20:14:08 -0500 (EST)
Message-ID: <20140302.201408.1852916497663090292.davem@davemloft.net>
References: <20140227182220.25907.12758.stgit@dragon>
	<20140228121529.20347.38300.stgit@dragon>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, eric.dumazet@gmail.com,
	pablo@netfilter.org, netdev@vger.kernel.org, fw@strlen.de,
	kaber@trash.net
To: brouer@redhat.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20140228121529.20347.38300.stgit@dragon>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Fri, 28 Feb 2014 13:16:15 +0100

> This patchset change the conntrack locking and provides a huge
> performance improvements.

I no longer have any concerns, looks good to me.
