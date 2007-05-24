From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/2] ucc_geth: Fix MODULE_DEVICE_TABLE() duplication
Date: Thu, 24 May 2007 17:20:59 -0400
Message-ID: <465601BB.9070107@garzik.org>
References: <4652E105.70806@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Li Yang <leoli@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48001 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751367AbXEXVVB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 May 2007 17:21:01 -0400
In-Reply-To: <4652E105.70806@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Li Yang wrote:
> Fix MODULE_DEVICE_TABLE() duplication in ucc_geth.c and ucc_geth_mii.c
> for ucc_geth to be compiled as module.
> 
> Signed-off-by: Li Yang <leoli@freescale.com>
> ---
> drivers/net/ucc_geth_mii.c |    2 --
> 1 files changed, 0 insertions(+), 2 deletions(-)

applied 1-2


