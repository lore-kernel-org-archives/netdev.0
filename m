From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [net] etherh: Add MAINTAINERS entry for etherh
Date: Sat, 5 Nov 2011 10:33:18 +0000
Message-ID: <20111105103318.GF12913@n2100.arm.linux.org.uk>
References: <1320447521-14270-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com, Joe Perches <joe@perches.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:42363 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752135Ab1KEKdg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Nov 2011 06:33:36 -0400
Content-Disposition: inline
In-Reply-To: <1320447521-14270-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 04, 2011 at 03:58:41PM -0700, Jeff Kirsher wrote:
> During the re-organization of Ethernet drivers, the MAINTAINERS
> entry for etherh got dropped accidentally.
> 
> CC: Russell King <linux@arm.linux.org.uk>

Thanks Jeff.

Acked-by: Russell King <rmk+kernel@arm.linux.org.uk>

> CC: Joe Perches <joe@perches.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  MAINTAINERS |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/MAINTAINERS b/MAINTAINERS
> index a6afe34..ecb2299 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -1032,6 +1032,7 @@ F:	arch/arm/include/asm/hardware/ioc.h
>  F:	arch/arm/include/asm/hardware/iomd.h
>  F:	arch/arm/include/asm/hardware/memc.h
>  F:	arch/arm/mach-rpc/
> +F:	drivers/net/ethernet/8390/etherh.c
>  F:	drivers/net/ethernet/i825xx/ether1*
>  F:	drivers/net/ethernet/seeq/ether3*
>  F:	drivers/scsi/arm/
> -- 
> 1.7.6.4
> 
