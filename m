From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: linux-next: manual merge of the net-next tree with the net tree
Date: Mon, 7 Nov 2016 22:34:11 -0800
Message-ID: <CAM_iQpU1p8aJy_64muXhszzYMzC8AZtRC7+1bB7f4hK+6-rSNQ@mail.gmail.com>
References: <20161108122537.40fa6e58@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>, linux-next@vger.kernel.org,
        LKML <linux-kernel@vger.kernel.org>,
        Johannes Berg <johannes.berg@intel.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20161108122537.40fa6e58@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 7, 2016 at 5:25 PM, Stephen Rothwell <sfr@canb.auug.org.au> wrote:
> Hi all,
>
> Today's linux-next merge of the net-next tree got a conflict in:
>
>   net/netlink/genetlink.c
>
> between commit:
>
>   00ffc1ba02d8 ("genetlink: fix a memory leak on error path")
>
> from the net tree and commit:
>
>   2ae0f17df1cd ("genetlink: use idr to track families")
>
> from the net-next tree.
>
> I fixed it up (see below) and can carry the fix as necessary. This
> is now fixed as far as linux-next is concerned, but any non trivial
> conflicts should be mentioned to your upstream maintainer when your tree
> is submitted for merging.  You may also want to consider cooperating
> with the maintainer of the conflicting tree to minimise any particularly
> complex conflicts.

Looks good to me.

Thanks!
