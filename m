From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Remove redundant NAPI functions
Date: Fri, 09 Jan 2009 23:06:42 -0800 (PST)
Message-ID: <20090109.230642.212150057.davem@davemloft.net>
References: <1231446610.3893.17.camel@achroite>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, shemminger@vyatta.com, jarkao2@gmail.com,
	netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46994
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751082AbZAJHGl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jan 2009 02:06:41 -0500
In-Reply-To: <1231446610.3893.17.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 08 Jan 2009 20:30:10 +0000

> Following the removal of the unused struct net_device * parameter from
> the NAPI functions named *netif_rx_* in commit 908a7a1, they are
> exactly equivalent to the corresponding *napi_* functions and are
> therefore redundant.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
