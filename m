From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v5 2/2] net: Add support for NTB virtual ethernet device
Date: Thu, 15 Nov 2012 16:30:43 -0800
Message-ID: <20121116003043.GC20876@kroah.com>
References: <1352160669-4330-1-git-send-email-jon.mason@intel.com>
 <1352160669-4330-3-git-send-email-jon.mason@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org, Dave Jiang <dave.jiang@intel.com>,
	Nicholas Bellinger <nab@linux-iscsi.org>
To: Jon Mason <jon.mason@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1352160669-4330-3-git-send-email-jon.mason@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 05, 2012 at 05:11:09PM -0700, Jon Mason wrote:
> A virtual ethernet device that uses the NTB transport API to
> send/receive data.
> 
> Signed-off-by: Jon Mason <jon.mason@intel.com>
> Reviewed-by: Nicholas Bellinger <nab@linux-iscsi.org>
> ---
>  MAINTAINERS              |    1 +
>  drivers/net/Kconfig      |    4 +
>  drivers/net/Makefile     |    1 +
>  drivers/net/ntb_netdev.c |  415 ++++++++++++++++++++++++++++++++++++++++++++++

As I haven't taken the core yet, I can't take this.  But even then, I
would need an ack from the network maintainers before I could.

And are you sure this is in the correct location in the tree?

thanks,

greg k-h
