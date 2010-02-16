From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH -mm] ssb: open-code dma_alloc_coherent
Date: Mon, 15 Feb 2010 18:09:53 -0600
Message-ID: <4B79E251.3020005@lwfinger.net>
References: <20100215142111R.fujita.tomonori@lab.ntt.co.jp>	<4B78EE6A.3010207@lwfinger.net> <20100215162426V.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org, mb@bu3sch.de,
	davem@davemloft.net, stefano.brivio@polimi.it,
	akpm@linux-foundation.org
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100215162426V.fujita.tomonori@lab.ntt.co.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/15/2010 01:25 AM, FUJITA Tomonori wrote:
> 2.6.33-rc8:
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/tomo/linux-2.6-misc.git pending
> 
> The ssb patch depends on the latest eight patches in the tree:
> 
> http://marc.info/?l=linux-kernel&m=126596737604808&w=2

The DMA changes work on i386 architecture with wireless devices in Cardbus (PCI)
format. Both b43legacy and b43 were tested.

Larry
