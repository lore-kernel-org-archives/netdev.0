From: Bert Kenward <bkenward@solarflare.com>
Subject: Re: [PATCH 11/15] sfc: don't call dma_supported
Date: Mon, 5 Oct 2015 16:08:22 +0100
Message-ID: <56129266.8070600@solarflare.com>
References: <1443885579-7094-1-git-send-email-hch@lst.de>
 <1443885579-7094-12-git-send-email-hch@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>,
	<dri-devel@lists.freedesktop.org>, <linux-media@vger.kernel.org>,
	<netdev@vger.kernel.org>, <linux-parisc@vger.kernel.org>,
	<linux-serial@vger.kernel.org>, <linux-usb@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Christoph Hellwig <hch@lst.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Don Fry <pcnet32@frontier.com>,
	Oliver Neukum <oneukum@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443885579-7094-12-git-send-email-hch@lst.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/10/15 16:19, Christoph Hellwig wrote:
> dma_set_mask already checks for a supported DMA mask before updating it,
> the call to dma_supported is redundant.
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Acked-by: Bert Kenward <bkenward@solarflare.com>
