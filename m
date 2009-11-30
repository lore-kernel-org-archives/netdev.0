From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/12] sfc: Remove redundant writes to INT_ADR_KER
Date: Sun, 29 Nov 2009 16:47:39 -0800 (PST)
Message-ID: <20091129.164739.157913636.davem@davemloft.net>
References: <1259502123.3709.40.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57077
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751851AbZK3Are (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2009 19:47:34 -0500
In-Reply-To: <1259502123.3709.40.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Sun, 29 Nov 2009 13:42:03 +0000

> This register only needs to be written after reset, not each time we
> enable interrupts.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
