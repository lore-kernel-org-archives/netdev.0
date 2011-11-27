From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 8/8] staging: octeon_ethernet: Convert to use device tree.
Date: Sat, 26 Nov 2011 18:04:44 -0800
Message-ID: <20111127020444.GA32071@kroah.com>
References: <1320978124-13042-1-git-send-email-ddaney.cavm@gmail.com>
 <1320978124-13042-9-git-send-email-ddaney.cavm@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-mips@linux-mips.org, ralf@linux-mips.org,
	devicetree-discuss@lists.ozlabs.org, grant.likely@secretlab.ca,
	linux-kernel@vger.kernel.org, David Daney <david.daney@cavium.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@suse.de>, devel@driverdev.osuosl.org
To: ddaney.cavm@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1320978124-13042-9-git-send-email-ddaney.cavm@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 10, 2011 at 06:22:04PM -0800, ddaney.cavm@gmail.com wrote:
> From: David Daney <david.daney@cavium.com>
> 
> Get MAC address and PHY connection from the device tree.
> 
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: netdev@vger.kernel.org
> Cc: Greg Kroah-Hartman <gregkh@suse.de>

Acked-by: Greg Kroah-Hartman <gregkh@suse.de>

This usually goes through the MIPS tree, so I'll let Ralf take it.

thanks,

greg k-h
