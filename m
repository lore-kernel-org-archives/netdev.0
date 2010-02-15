From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: Re: [PATCH -mm] ssb: open-code dma_alloc_coherent
Date: Mon, 15 Feb 2010 16:25:14 +0900
Message-ID: <20100215162426V.fujita.tomonori@lab.ntt.co.jp>
References: <20100215142111R.fujita.tomonori@lab.ntt.co.jp>
	<4B78EE6A.3010207@lwfinger.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fujita.tomonori@lab.ntt.co.jp, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, mb@bu3sch.de, davem@davemloft.net,
	stefano.brivio@polimi.it, akpm@linux-foundation.org
To: Larry.Finger@lwfinger.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4B78EE6A.3010207@lwfinger.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 15 Feb 2010 00:49:14 -0600
Larry Finger <Larry.Finger@lwfinger.net> wrote:

> On 02/14/2010 11:21 PM, FUJITA Tomonori wrote:
> > This patch is against -mm since it depends on the DMA API changes in
> > -mm.
> 
> Are the patches that implement these DMA API changes available for testing? I
> don't keep an -mm tree.

All the patches are in -mm and I've just uploaded the patches against
2.6.33-rc8:

git://git.kernel.org/pub/scm/linux/kernel/git/tomo/linux-2.6-misc.git pending

The ssb patch depends on the latest eight patches in the tree:

http://marc.info/?l=linux-kernel&m=126596737604808&w=2



Thanks!
