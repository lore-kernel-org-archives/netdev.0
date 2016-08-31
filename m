From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v6 0/8] thunderbolt: Introducing Thunderbolt(TM)
 networking
Date: Wed, 31 Aug 2016 13:28:13 +0200
Message-ID: <20160831112813.GB17607@kroah.com>
References: <1470054233-4309-1-git-send-email-amir.jer.levy@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andreas.noever@gmail.com, bhelgaas@google.com, corbet@lwn.net,
        linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org,
        netdev@vger.kernel.org, linux-doc@vger.kernel.org,
        thunderbolt-linux@intel.com, mika.westerberg@intel.com,
        tomas.winkler@intel.com
To: Amir Levy <amir.jer.levy@intel.com>
Return-path: <linux-doc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1470054233-4309-1-git-send-email-amir.jer.levy@intel.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 01, 2016 at 03:23:45PM +0300, Amir Levy wrote:
> This is version 6 of Thunderbolt(TM) driver for non-Apple hardware.
> 
> Changes since v5:
>  - Removed the padding of short packets in receive
>  - Replaced RW semaphore with mutex
>  - Cleanup
> 
> These patches were pushed to GitHub where they can be reviewed more
> comfortably with green/red highlighting:
> 	https://github.com/01org/thunderbolt-software-kernel-tree
> 
> Daemon code:
> 	https://github.com/01org/thunderbolt-software-daemon
> 
> For reference, here's a link to version 5:
> [v5]:	https://lkml.org/lkml/2016/7/28/85

Without acks from the thunderbolt maintainer, or any network driver
developers, I'm not going to take this series.  Please work to get that
review.

thanks,

greg k-h
