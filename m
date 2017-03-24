From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: manual merge of the net-next tree with Linus' tree
Date: Thu, 23 Mar 2017 17:10:35 -0700 (PDT)
Message-ID: <20170323.171035.27948034948873194.davem@davemloft.net>
References: <20170324110514.0376c46f@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
        linux-kernel@vger.kernel.org, ast@fb.com, kafai@fb.com
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20170324110514.0376c46f@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Fri, 24 Mar 2017 11:05:14 +1100

> Hi all,
> 
> Today's linux-next merge of the net-next tree got a conflict in:
> 
>   kernel/bpf/hashtab.c
> 
> between commit:
> 
>   8c290e60fa2a ("bpf: fix hashmap extra_elems logic")
> 
> from Linus' tree and commit:
> 
>   bcc6b1b7ebf8 ("bpf: Add hash of maps support")
> 
> from the net-next tree.
> 
> I fixed it up (see below) and can carry the fix as necessary. This
> is now fixed as far as linux-next is concerned, but any non trivial
> conflicts should be mentioned to your upstream maintainer when your tree
> is submitted for merging.  You may also want to consider cooperating
> with the maintainer of the conflicting tree to minimise any particularly
> complex conflicts.

I did the same resolution just an hour ago when merging net into
net-next.

Thanks!
