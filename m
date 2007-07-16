From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/1] 8139cp: implement the missing dev->tx_timeout
Date: Mon, 16 Jul 2007 18:30:13 -0400
Message-ID: <469BF175.1040107@garzik.org>
References: <4693B6ED.5030102@garzik.org> <OF89ECFC4B.E1AA259B-ONC2257315.002C3B4B-C2257317.0054CDE1@stonesoft.com> <20070713210535.GB18669@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mika.Lansirinne@stonesoft.com, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:37287 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759244AbXGPWaR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jul 2007 18:30:17 -0400
In-Reply-To: <20070713210535.GB18669@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> Signed-off-by: Mika Lansirinne <mika.lansirinne@stonesoft.com>
> ---
>  drivers/net/8139cp.c |   27 ++++++++++++++++++++++++---
>  1 files changed, 24 insertions(+), 3 deletions(-)

applied, thanks for helping out Francois


