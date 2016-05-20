From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build warnings after merge of the net tree
Date: Thu, 19 May 2016 22:57:23 -0700 (PDT)
Message-ID: <20160519.225723.702095889957599536.davem@davemloft.net>
References: <20160520133330.12a1aa65@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, xypron.glpk@gmx.de
To: sfr@canb.auug.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160520133330.12a1aa65@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Fri, 20 May 2016 13:33:30 +1000

> After merging the net tree, today's linux-next build (arm
> multi_v7_defconfig) produced these warnings:
 ...
> Introduced by commit
> 
>   e00be9e4d0ff ("net: pegasus: remove dead coding")

This change has other problems too and I have just reverted it.

Thanks.
