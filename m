From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/6] cxgb: delete non NAPI code from the driver.
Date: Fri, 11 Jul 2008 01:14:44 -0400
Message-ID: <4876EC44.2040306@garzik.org>
References: <20080707.224336.59099363.davem@davemloft.net> <20080708070106.GA30382@electric-eye.fr.zoreil.com> <20080708.015548.127198943.davem@davemloft.net> <20080710222919.GA31019@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Divy Le Ray <divy@chelsio.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46495 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752143AbYGKFOt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jul 2008 01:14:49 -0400
In-Reply-To: <20080710222919.GA31019@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu wrote:
> Compile-tested only.
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> ---
>  drivers/net/Kconfig         |    8 -----
>  drivers/net/chelsio/cxgb2.c |    2 -
>  drivers/net/chelsio/sge.c   |   70 +++---------------------------------------
>  3 files changed, 5 insertions(+), 75 deletions(-)

applied:  cxgb (this patch), via-rhine, gianfar, ucc_geth


