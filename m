From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: linux-next: manual merge of the akpm tree with the net-next tree
Date: Wed, 20 Feb 2013 14:43:02 +0800
Message-ID: <51247076.5000003@gmail.com>
References: <20130220170223.806c3c5e9f240d8bacc7c940@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Sasha Levin <sasha.levin@oracle.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20130220170223.806c3c5e9f240d8bacc7c940@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/20/2013 02:02 PM, Stephen Rothwell wrote:
> Hi Andrew,
>
> Today's linux-next merge of the akpm tree got a conflict in
> net/core/dev.c between commit 900ff8c63214 ("net: move procfs code to
> net/core/net-procfs.c") from the net-next tree and commit "hlist: drop
> the node parameter from iterators" from the akpm tree.
>
> I fixed it up (see below) and can carry the fix as necessary (no action
> is required).
>

Looks good.

Thanks, Stephen!
