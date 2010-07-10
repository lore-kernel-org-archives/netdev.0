From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 2/2] net: Document that dev_get_stats()
 returns the given pointer
Date: Fri, 09 Jul 2010 18:01:59 -0700 (PDT)
Message-ID: <20100709.180159.39178827.davem@davemloft.net>
References: <1278702713.2078.13.camel@achroite.uk.solarflarecom.com>
	<1278702761.2078.14.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	eric.dumazet@gmail.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37971
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751452Ab0GJBBo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jul 2010 21:01:44 -0400
In-Reply-To: <1278702761.2078.14.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 09 Jul 2010 20:12:41 +0100

> Document that dev_get_stats() returns the same stats pointer it was
> given.  Remove const qualification from the returned pointer since the
> caller may do what it likes with that structure.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
