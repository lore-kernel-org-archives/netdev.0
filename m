From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 08/21] NTB: declare unused variables
Date: Sun, 20 Jan 2013 15:42:28 -0800
Message-ID: <20130120234228.GC14196@kroah.com>
References: <1358586155-23322-1-git-send-email-jon.mason@intel.com>
 <1358586155-23322-9-git-send-email-jon.mason@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Dave Jiang <dave.jiang@intel.com>,
	Nicholas Bellinger <nab@linux-iscsi.org>
To: Jon Mason <jon.mason@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1358586155-23322-9-git-send-email-jon.mason@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 19, 2013 at 02:02:22AM -0700, Jon Mason wrote:
> Tag pci_device_id in ntb_pci_probe as unused function parameters.  This
> corrects issues found by 'EXTRA_CFLAGS=-W'.

Why would you build the kernel with that option?  This isn't needed, so
I'm not going to apply it.

thanks,

greg k-h
