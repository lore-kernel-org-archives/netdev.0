From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] ip6_tunnel: Add support for wildcard
 tunnel endpoints.
Date: Thu, 06 Nov 2014 14:19:46 -0500 (EST)
Message-ID: <20141106.141946.1716048601530236678.davem@davemloft.net>
References: <20141105070248.GC6390@secunet.com>
	<20141105070350.GD6390@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57690 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751262AbaKFTTu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 14:19:50 -0500
In-Reply-To: <20141105070350.GD6390@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Wed, 5 Nov 2014 08:03:50 +0100

> This patch adds support for tunnels with local or
> remote wildcard endpoints. With this we get a
> NBMA tunnel mode like we have it for ipv4 and
> sit tunnels.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

Applied.
