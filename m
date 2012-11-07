From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/7] be2net: patch set
Date: Wed, 07 Nov 2012 17:00:40 -0500 (EST)
Message-ID: <20121107.170040.1773285592911901009.davem@davemloft.net>
References: <4f3dfb12-ef85-48ce-9c67-f5e58ed6f105@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41526 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752377Ab2KGWAl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2012 17:00:41 -0500
In-Reply-To: <4f3dfb12-ef85-48ce-9c67-f5e58ed6f105@CMEXHTCAS2.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Wed, 7 Nov 2012 09:18:54 +0530

> Pls apply.
> 
> Sathya Perla (7):
>   be2net: remove LANCER A0 workaround
>   be2net: fix wrong usage of adapter->generation
>   be2net: do not use sli_family to identify skyhawk-R chip
>   be2net: re-factor bar mapping code
>   be2net: fix access to SEMAPHORE reg
>   be2net: remove roce on lancer
>   be2net: remove adapter->eq_next_idx

Looks good, all applied to net-next, thanks.
