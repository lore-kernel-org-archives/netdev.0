From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] [NET]: Remove PowerPC code from fec.c
Date: Wed, 30 Jan 2008 03:41:20 -0500
Message-ID: <47A03830.7070907@pobox.com>
References: <4799F349.9090102@scram.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Vitaly Bordug <vitb@kernel.crashing.org>,
	Scott Wood <scottwood@freescale.com>,
	Kumar Gala <galak@kernel.crashing.org>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	"Kernel, Linux" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linuxppc-dev list <linuxppc-dev@ozlabs.org>,
	linux-m68k@vger.kernel.org
To: Jochen Friedrich <jochen@scram.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47068 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754591AbYA3Ilb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2008 03:41:31 -0500
In-Reply-To: <4799F349.9090102@scram.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jochen Friedrich wrote:
> fec.c is only used on M68k Coldfire CPUs. Remove leftover
> PowerPC code from this driver.
> 
> Signed-off-by: Jochen Friedrich <jochen@scram.de>
> ---
>  drivers/net/fec.c |  136 +---------------------------------------------------
>  1 files changed, 3 insertions(+), 133 deletions(-)

Seems OK to me, but I feel I don't have enough knowledge to ACK or NAK. 
  Please pass through an arch tree, thanks.

	Jeff



