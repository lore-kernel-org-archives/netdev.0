From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: alx: handle pci_alloc_irq_vectors return correctly
Date: Fri, 05 May 2017 14:52:47 -0400 (EDT)
Message-ID: <20170505.145247.613295044455415425.davem@davemloft.net>
References: <20170505112823.GA4019@hercules.tuxera.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jcliburn@gmail.com, chris.snook@gmail.com,
        tobias.regnery@gmail.com, feng.tang@intel.com, edumazet@google.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org, hch@lst.de
To: rakesh@tuxera.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170505112823.GA4019@hercules.tuxera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rakesh Pandit <rakesh@tuxera.com>
Date: Fri, 5 May 2017 14:28:23 +0300

> It was introduced while switching to pci_alloc_irq_vectors recently
> and fixes:
 ...
> Fixes: f3297f68 ("net: alx: switch to pci_alloc_irq_vectors")
> Signed-off-by: Rakesh Pandit <rakesh@tuxera.com>

Applied, thanks.
