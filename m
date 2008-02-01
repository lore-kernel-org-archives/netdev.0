From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] PHYLIB: Add BCM5482 PHY support
Date: Fri, 01 Feb 2008 13:41:46 -0500
Message-ID: <47A367EA.80101@garzik.org>
References: <1201623540.12444.121.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andy Fleming <afleming@freescale.com>,
	netdev <netdev@vger.kernel.org>
To: Nate Case <ncase@xes-inc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54967 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755929AbYBASlt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2008 13:41:49 -0500
In-Reply-To: <1201623540.12444.121.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nate Case wrote:
> This Broadcom PHY is similar to other bcm54xx devices.
> 
> Signed-off-by: Nate Case <ncase@xes-inc.com>
> ---
>  drivers/net/phy/broadcom.c |   20 ++++++++++++++++++++
>  1 files changed, 20 insertions(+), 0 deletions(-)

applied


