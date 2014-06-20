From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net]tg3: Clear NETIF_F_TSO6 flag before doing software
 GSO
Date: Fri, 20 Jun 2014 16:30:24 -0700 (PDT)
Message-ID: <20140620.163024.638124458221479046.davem@davemloft.net>
References: <1403141893-21735-1-git-send-email-prashant@broadcom.com>
	<20140619.205657.498263585409423061.davem@davemloft.net>
	<1403241085.2488.53.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: prashant@broadcom.com, netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57212 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751386AbaFTXa3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2014 19:30:29 -0400
In-Reply-To: <1403241085.2488.53.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <mchan@broadcom.com>
Date: Thu, 19 Jun 2014 22:11:25 -0700

> David, the regression is only in the net tree.  It doesn't hurt to send
> the patch to -stable, but not necessary.

Ok, I've dequeued it.
