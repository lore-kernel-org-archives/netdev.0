From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] AT91: MACB support
Date: Wed, 07 Feb 2007 17:28:30 -0500
Message-ID: <45CA528E.9000602@garzik.org>
References: <1170862844979-git-send-email-hskinnemoen@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Patrice Vilchez <patrice.vilchez@rfo.atmel.com>,
	Andrew Victor <andrew@sanpeople.com>
To: Haavard Skinnemoen <hskinnemoen@atmel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:37963 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161454AbXBGW2e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Feb 2007 17:28:34 -0500
In-Reply-To: <1170862844979-git-send-email-hskinnemoen@atmel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Haavard Skinnemoen wrote:
> From: Andrew Victor <andrew@sanpeople.com>
> 
> The Atmel MACB Ethernet peripheral is also integrated in the AT91SAM9260
> and AT91SAM9263 processors.  The differences from the AVR32 version are:
>       * Single peripheral clock.
>       * MII/RMII selection bit is inverted.
>       * Clock enable bit.
> 
> Original patch from Patrice Vilchez.
> 
> Signed-off-by: Andrew Victor <andrew@sanpeople.com>
> Signed-off-by: Haavard Skinnemoen <hskinnemoen@atmel.com>
> ---
>  drivers/net/Kconfig |    2 +-
>  drivers/net/macb.c  |   25 +++++++++++++++++++++++--
>  drivers/net/macb.h  |    8 +++++++-
>  3 files changed, 31 insertions(+), 4 deletions(-)

applied


