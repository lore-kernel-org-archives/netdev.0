From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH -mm] ssb: open-code dma_alloc_coherent
Date: Mon, 15 Feb 2010 12:21:04 +0100
Message-ID: <201002151221.04758.mb@bu3sch.de>
References: <20100215142111R.fujita.tomonori@lab.ntt.co.jp> <201002151203.42805.mb@bu3sch.de> <20100215201825M.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, stefano.brivio@polimi.it,
	Larry.Finger@lwfinger.net, akpm@linux-foundation.org
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100215201825M.fujita.tomonori@lab.ntt.co.jp>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 15 February 2010 12:18:41 FUJITA Tomonori wrote:
> You can use the generic DMA API with any buses. I'll remove the PCI
> DMA API in the long term.

Cool. Thanks a lot for cleaning up the mess. *thumbs up*

-- 
Greetings, Michael.
