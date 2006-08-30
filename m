From: David Miller <davem@davemloft.net>
Subject: Re: [-mm patch] net/sched/act_simple.c: make struct simp_hash_info
 static
Date: Wed, 30 Aug 2006 15:03:37 -0700 (PDT)
Message-ID: <20060830.150337.115914733.davem@davemloft.net>
References: <20060826160922.3324a707.akpm@osdl.org>
	<20060830203507.GL18276@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932157AbWH3WDh@vger.kernel.org>
To: bunk@stusta.de
In-Reply-To: <20060830203507.GL18276@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>
Date: Wed, 30 Aug 2006 22:35:07 +0200

> On Sat, Aug 26, 2006 at 04:09:22PM -0700, Andrew Morton wrote:
> >...
> > Changes since 2.6.18-rc4-mm2:
> >...
> >  git-net.patch
> >...
> >  git trees
> >...
> 
> This patch makes the needlessly global struct simp_hash_info static.
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

Applied, thanks Adrian.
