From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] [NET] smc91x: provide configurable leds
Date: Wed, 03 Sep 2008 09:25:11 -0400
Message-ID: <48BE9037.9090403@pobox.com>
References: <20080827115254.GB2899@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46133 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751751AbYICNZQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2008 09:25:16 -0400
In-Reply-To: <20080827115254.GB2899@flint.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Russell King - ARM Linux wrote:
> This patch provides a mechanism for platforms to be able to supply the
> LED configuration via platform data, rather than having to hard code
> it in smc91x.h.
> 
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
> Tested-by: Marc Zyngier <maz@misterjones.org>
> Acked-by: Nicolas Pitre <nico@cam.org>
> 
> --
> As noticed by Eric against the Viper patches, being able to configure
> the LEDs from platform code would be a good idea.  This patch implements
> a mechanism to allow that to happen.
> 
> Since ARM platforms will depend on this, I'd prefer to add it to the
> ARM tree, so I'm after an Ack from networking people.

ACK


