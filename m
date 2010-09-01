From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 8/8] bnx2x: Update version to 1.52.53-5
Date: Wed, 01 Sep 2010 09:44:18 -0700
Message-ID: <1283359458.1797.190.camel@Joe-Laptop>
References: <1283370697.4403.139.camel@lb-tlvb-yanivr.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, eilong@broadcom.com
To: Yaniv Rosner <yaniv.rosner@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1201 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753524Ab0IAQoV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Sep 2010 12:44:21 -0400
In-Reply-To: <1283370697.4403.139.camel@lb-tlvb-yanivr.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-09-01 at 22:51 +0300, Yaniv Rosner wrote:
>  drivers/net/bnx2x/bnx2x.h |    4 ++--
> +++ b/drivers/net/bnx2x/bnx2x.h
> -#define DRV_MODULE_VERSION      "1.52.53-4"
> -#define DRV_MODULE_RELDATE      "2010/16/08"
> +#define DRV_MODULE_VERSION      "1.52.53-5"
> +#define DRV_MODULE_RELDATE      "2010/01/09"
>  #define BNX2X_BC_VER            0x040200

Your date scheme is very odd.

yyyy/dd/mm?

Where in the world is that used?


