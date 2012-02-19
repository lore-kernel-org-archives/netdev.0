From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: manual merge of the net-next tree with the net tree
Date: Sun, 19 Feb 2012 17:41:00 -0500 (EST)
Message-ID: <20120219.174100.25858072359685481.davem@davemloft.net>
References: <20120216123803.8efe3d23eee5c3a80aceef61@canb.auug.org.au>
	<1329391450.16698.27.camel@lb-tlvb-eilong.il.broadcom.com>
	<20120217103011.b2223e28a89839d09a4a4053@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yuvalmin@broadcom.com, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	eilong@broadcom.com, eric.dumazet@gmail.com
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20120217103011.b2223e28a89839d09a4a4053@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Fri, 17 Feb 2012 10:30:11 +1100

> Hi,
> 
> On Thu, 16 Feb 2012 13:24:10 +0200 "Yuval Mintz" <yuvalmin@broadcom.com> wrote:
>>
>> I don't fully understand your merge - it seems to create a mash between
>> the "bnx2x: fix bnx2x_storm_stats_update() on big endian" patch in net,
>> and the "bnx2x: consistent statistics after internal driver reload"
>> patch in net-next.
> 
> That is exactly what the merge conflict resolution did.  i.e. the patch
> you supplied below is not needed in linux-next because that is
> effectively what I did.  It is the same as Dave will do when he merges
> the net tree into the net-next tree as well, I assume.

I've taken care of this.
