From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/11] ibm_newemac: Add BCM5248 and Marvell 88E1111 PHY
 support
Date: Fri, 07 Dec 2007 15:09:20 -0500
Message-ID: <4759A870.8030900@pobox.com>
References: <20071205001534.D681ADDF2D@ozlabs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	Josh Boyer <jwboyer@linux.vnet.ibm.com>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:57746 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756078AbXLGUJX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Dec 2007 15:09:23 -0500
In-Reply-To: <20071205001534.D681ADDF2D@ozlabs.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benjamin Herrenschmidt wrote:
> From: Stefan Roese <sr@denx.de>
> 
> This patch adds BCM5248 and Marvell 88E1111 PHY support to NEW EMAC driver.
> These PHY chips are used on PowerPC 440EPx boards.
> The PHY code is based on the previous work by Stefan Roese <sr@denx.de>
> 
> Signed-off-by: Stefan Roese <sr@denx.de>
> Signed-off-by: Valentine Barshak <vbarshak@ru.mvista.com>
> Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> ---
> 
>  drivers/net/ibm_newemac/phy.c |   39 +++++++++++++++++++++++++++++++++++++++
>  1 file changed, 39 insertions(+)

applied 1-11 #upstream-fixes


