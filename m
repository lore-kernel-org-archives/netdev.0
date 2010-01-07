From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sky2: Refactor sky2_get_regs into two functions
Date: Wed, 06 Jan 2010 20:26:34 -0800 (PST)
Message-ID: <20100106.202634.165976580.davem@davemloft.net>
References: <4B3C81C7.9040108@ring3k.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: mikem@ring3k.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33739
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752351Ab0AGE00 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2010 23:26:26 -0500
In-Reply-To: <4B3C81C7.9040108@ring3k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike McCormack <mikem@ring3k.org>
Date: Thu, 31 Dec 2009 19:49:43 +0900

> Subject: [PATCH] sky2: Refactor sky2_get_regs into two functions
> 
> Separate code deciding which registers can be accessed out of sky2_get_regs
>  in preparation for adding more conditions into it.
> 
> Signed-off-by: Mike McCormack <mikem@ring3k.org>
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied to net-next-2.6
