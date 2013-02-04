From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] State resolution packet queue for IPsec
Date: Mon, 04 Feb 2013 12:47:00 -0500 (EST)
Message-ID: <20130204.124700.916487485033617618.davem@davemloft.net>
References: <20130121.161716.752461350033731834.davem@davemloft.net>
	<20130122111029.GF9147@secunet.com>
	<20130204082526.GE23291@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43491 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754416Ab3BDRrC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2013 12:47:02 -0500
In-Reply-To: <20130204082526.GE23291@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Mon, 4 Feb 2013 09:25:27 +0100

> I'd apply the timer version to ipsec-next if there are no objections.
> We can still tune it if something does not perform well.

Ok.
