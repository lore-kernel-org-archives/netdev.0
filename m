From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] net: NEWEMAC: Add compatible "ibm,tah" to tah matching
 table
Date: Mon, 17 Mar 2008 08:08:42 -0400
Message-ID: <47DE5F4A.9080303@garzik.org>
References: <1205423983-21142-1-git-send-email-sr@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	jwboyer@linux.vnet.ibm.com, benh@kernel.crashing.org
To: Stefan Roese <sr@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:42324 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754189AbYCQMIp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Mar 2008 08:08:45 -0400
In-Reply-To: <1205423983-21142-1-git-send-email-sr@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stefan Roese wrote:
> Add "ibm,tah" to the compatible matching table of the ibm_newemac
> tah driver. The type "tah" is still preserved for compatibility reasons.
> New dts files should use the compatible property though.
> 
> Signed-off-by: Stefan Roese <sr@denx.de>
> ---
>  drivers/net/ibm_newemac/tah.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)

applied


