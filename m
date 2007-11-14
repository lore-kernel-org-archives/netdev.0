From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Remove notifier block from chain when
 register_netdevice_notifier fails
Date: Wed, 14 Nov 2007 15:53:43 -0800 (PST)
Message-ID: <20071114.155343.119550455.davem@davemloft.net>
References: <473AE523.70501@openvz.org>
	<20071114133717.GA14746@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, netdev@vger.kernel.org, devel@openvz.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60465
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754449AbXKNXxo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 18:53:44 -0500
In-Reply-To: <20071114133717.GA14746@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 14 Nov 2007 21:37:17 +0800

> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Indeed, good catch, patch applied.

Thanks!
