From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] ucc_geth: use of_get_mac_address()
Date: Tue, 27 Feb 2007 04:22:44 -0500
Message-ID: <45E3F864.7020206@garzik.org>
References: <11720904121560-git-send-email-timur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Timur Tabi <timur@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47480 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161084AbXB0JWq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Feb 2007 04:22:46 -0500
In-Reply-To: <11720904121560-git-send-email-timur@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Timur Tabi wrote:
> Update ucc_geth_probe() to use function of_get_mac_address() to obtain the MAC
> address.
> 
> Signed-off-by: Timur Tabi <timur@freescale.com>
> ---
>  drivers/net/ucc_geth.c |    4 +---
>  1 files changed, 1 insertions(+), 3 deletions(-)

applied


