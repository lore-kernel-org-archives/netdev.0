From: David Miller <davem@davemloft.net>
Subject: Re: [git patch] net driver fix for .26
Date: Mon, 14 Jul 2008 19:36:34 -0700 (PDT)
Message-ID: <20080714.193634.207900782.davem@davemloft.net>
References: <20080711140952.GA17593@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56261
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1761690AbYGOCge (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2008 22:36:34 -0400
In-Reply-To: <20080711140952.GA17593@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Garzik <jeff@garzik.org>
Date: Fri, 11 Jul 2008 10:09:52 -0400

> 
> Please pull from 'davem-fixes' branch of
> master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git davem-fixes
> 
> to receive the following updates:
> 
>  drivers/net/arm/ixp4xx_eth.c |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)
> 
> Krzysztof Halasa (1):
>       ARM: IXP4xx Ethernet NAPI fix

Pulled, thanks Jeff.

This obviously didn't make it into 2.6.26, but if you think
it's relevant let me know and I'll queue it to -stable.
