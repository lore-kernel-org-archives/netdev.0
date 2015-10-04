From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 15/15] dma: remove external references to dma_supported
Date: Sun, 4 Oct 2015 10:57:34 +0100
Message-ID: <20151004095734.GB29706@kroah.com>
References: <1443885579-7094-1-git-send-email-hch@lst.de>
 <1443885579-7094-16-git-send-email-hch@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Don Fry <pcnet32@frontier.com>,
	Oliver Neukum <oneukum@suse.com>,
	linux-net-drivers@solarflare.com, dri-devel@lists.freedesktop.org,
	linux-media@vger.kernel.org, netdev@vger.kernel.org,
	linux-parisc@vger.kernel.org, linux-serial@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org
To: Christoph Hellwig <hch@lst.de>
Return-path: <linux-parisc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1443885579-7094-16-git-send-email-hch@lst.de>
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 03, 2015 at 05:19:39PM +0200, Christoph Hellwig wrote:
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  Documentation/DMA-API.txt       | 13 -------------
>  drivers/usb/host/ehci-hcd.c     |  2 +-
>  drivers/usb/host/fotg210-hcd.c  |  2 +-
>  drivers/usb/host/fusbh200-hcd.c |  2 +-
>  drivers/usb/host/oxu210hp-hcd.c |  2 +-
>  5 files changed, 4 insertions(+), 17 deletions(-)


Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
