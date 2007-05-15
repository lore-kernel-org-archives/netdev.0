From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 3/5] ucc_geth: eliminate max-speed, change interface-type
 to phy-connection-type
Date: Tue, 15 May 2007 17:45:19 -0400
Message-ID: <464A29EF.7080405@garzik.org>
References: <20070511182507.7642926e.kim.phillips@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Kim Phillips <kim.phillips@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:50845 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755790AbXEOVpV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 May 2007 17:45:21 -0400
In-Reply-To: <20070511182507.7642926e.kim.phillips@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kim Phillips wrote:
> It was agreed that phy-connection-type was a better name for
> the interface-type property, so this patch renames it.
> 
> Also, the max-speed property name was determined too generic,
> and is therefore eliminated in favour of phy-connection-type
> derivation logic.
> 
> includes corrections to copyright text.
> 
> Signed-off-by: Kim Phillips <kim.phillips@freescale.com>
> ---
>  drivers/net/ucc_geth.c     |   40 ++++++++++++++++------------------------
>  drivers/net/ucc_geth_mii.c |    9 +++++----
>  drivers/net/ucc_geth_mii.h |   10 +++++-----
>  3 files changed, 26 insertions(+), 33 deletions(-)

applied to #upstream


