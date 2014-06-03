From: Greg KH <greg@kroah.com>
Subject: Re: Request for stable inclusion
Date: Tue, 3 Jun 2014 16:12:00 -0700
Message-ID: <20140603231200.GD16316@kroah.com>
References: <alpine.DEB.2.02.1404302055200.6261@ionos.tec.linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stable@vger.kernel.org, Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	David Ertman <davidx.m.ertman@intel.com>,
	netdev@vger.kernel.org
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1404302055200.6261@ionos.tec.linutronix.de>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 30, 2014 at 09:03:36PM +0200, Thomas Gleixner wrote:
> Hi,
> 
> commit b20a774495671f037e7160ea2ce8789af6b61533
> Author: David Ertman <davidx.m.ertman@intel.com>
> Date:   Tue Mar 25 04:27:55 2014 +0000
> 
>     e1000e: Fix no connectivity when driver loaded with cable out
> 
> fixes an issue which affects quite some of the newer Laptops and also
> Desktops (e.g. AOI-PCs) which are based on mobile chipsets.
> 
> I don't know how far this reaches back, but at least the 3.13 and 3.14
> kernels need this fix. Jeff, David, can you tell?

Now applied to 3.14-stable, thanks.

greg k-h
