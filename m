From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 3/6] phylib: enable RGMII-ID on the Marvell m88e1111 PHY
Date: Wed, 09 May 2007 19:37:20 -0400
Message-ID: <46425B30.7050005@garzik.org>
References: <20070508175019.6b10eff0.kim.phillips@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Kim Phillips <kim.phillips@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:50180 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756687AbXEIXhW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 May 2007 19:37:22 -0400
In-Reply-To: <20070508175019.6b10eff0.kim.phillips@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kim Phillips wrote:
> Support for configuring RGMII-ID (RGMII with internal delay) mode on the
> 88e1111 and 88e1145.
> 
> Also renamed 88e1111s -> 88e1111 (no references to an 88e1111s part were
> found), and fixed some whitespace.
> 
> Signed-off-by: Kim Phillips <kim.phillips@freescale.com>
> ---
>  drivers/net/phy/marvell.c |   62 +++++++++++++++++++++++++++++++++++++++------
>  1 files changed, 54 insertions(+), 8 deletions(-)

ACK 3-6


