From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/2] net: OpenFirmware GPIO based MDIO bitbang driver
Date: Fri, 30 May 2008 22:20:10 -0400
Message-ID: <4840B5DA.6020708@pobox.com>
References: <200805261152.37636.laurentp@cse-semaphore.com> <200805261153.21932.laurentp@cse-semaphore.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	Anton Vorontsov <avorontsov@ru.mvista.com>,
	Scott Wood <scottwood@freescale.com>
To: Laurent Pinchart <laurentp@cse-semaphore.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54309 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750914AbYEaCUN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 May 2008 22:20:13 -0400
In-Reply-To: <200805261153.21932.laurentp@cse-semaphore.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Laurent Pinchart wrote:
> This patch adds an MDIO bitbang driver that uses the GPIO library and its
> OF bindings to access the bus I/Os.
> 
> Signed-off-by: Laurent Pinchart <laurentp@cse-semaphore.com>
> ---
>  Documentation/powerpc/booting-without-of.txt |   21 +++
>  drivers/net/phy/Kconfig                      |    6 +
>  drivers/net/phy/Makefile                     |    1 +
>  drivers/net/phy/mdio-ofgpio.c                |  205 ++++++++++++++++++++++++++
>  4 files changed, 233 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/net/phy/mdio-ofgpio.c

applied 1-2


