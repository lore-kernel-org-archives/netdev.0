From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] s2io: add dynamic LRO disable support
Date: Mon, 28 Jun 2010 23:04:23 -0700 (PDT)
Message-ID: <20100628.230423.70193746.davem@davemloft.net>
References: <20100622085415.5566.22523.sendpatchset@localhost.localdomain>
	<20100625044510.GC2739@exar.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amwang@redhat.com, netdev@vger.kernel.org, nhorman@redhat.com,
	sgruszka@redhat.com, herbert.xu@redhat.com,
	bhutchings@solarflare.com, Ramkrishna.Vepa@exar.com
To: jon.mason@exar.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53695
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751456Ab0F2GEL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 02:04:11 -0400
In-Reply-To: <20100625044510.GC2739@exar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Mason <jon.mason@exar.com>
Date: Thu, 24 Jun 2010 23:45:10 -0500

> This patch adds dynamic LRO disable support for s2io net driver,
> enables LRO by default, increases the driver version number, and
> corrects the name of the LRO modparm.
> 
> This is mostly Wang's patch based on Neil's initial work, heavily
> modified based on Ramkrishna's suggestions.  This has been tested on
> a Neterion Xframe adapter and verified via adapter LRO statistics.
> 
> Signed-off-by: Jon Mason <jon.mason@exar.com>
> Signed-off-by: WANG Cong <amwang@redhat.com>
> Signed-off-by: Neil Horman <nhorman@redhat.com>
> Acked-by: Neil Horman <nhorman@redhat.com>
> Reviewed-by: Stanislaw Gruszka <sgruszka@redhat.com>
> Cc: Ramkrishna Vepa <Ramkrishna.Vepa@exar.com>

Applied to net-next-2.6
