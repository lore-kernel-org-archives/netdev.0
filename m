From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH] Remove pointless casts from void pointers,
Date: Fri, 26 Oct 2007 23:58:05 +0200
Message-ID: <20071026215805.GD32372@xi.wantstofly.org>
References: <9799624f63e093aa915947aea8fb1b8a5df959a1.1193390973.git.jeff@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>, akpm@linux-foundation.org,
	rmk@arm.linux.org.uk, kernel@wantstofly.org, tony.luck@intel.com,
	jwboyer@linux.vnet.ibm.com, benh@kernel.crashing.org,
	paulus@samba.org, dmitry.torokhov@gmail.com,
	netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	linux-serial@vger.kernel.org, linux-wireless@vger.kernel.org,
	bryan.wu@analog.com, adaplas@gmail.com
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:53342 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750798AbXJZV6H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2007 17:58:07 -0400
Content-Disposition: inline
In-Reply-To: <9799624f63e093aa915947aea8fb1b8a5df959a1.1193390973.git.jeff@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 26, 2007 at 05:40:22AM -0400, Jeff Garzik wrote:

>  arch/arm/mach-pxa/ssp.c                    |    2 +-
>  arch/arm/mach-s3c2410/usb-simtec.c         |    2 +-
>  arch/arm/plat-omap/mailbox.c               |    2 +-

FWIW

Acked-by: Lennert Buytenhek <buytenh@wantstofly.org>
