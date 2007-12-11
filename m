From: David Miller <davem@davemloft.net>
Subject: Re: [RFC 0/3] Add AEAD support to ESP
Date: Tue, 11 Dec 2007 02:09:08 -0800 (PST)
Message-ID: <20071211.020908.132417910.davem@davemloft.net>
References: <20071211042312.GA10911@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42023
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751180AbXLKKJJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 05:09:09 -0500
In-Reply-To: <20071211042312.GA10911@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 11 Dec 2007 12:23:12 +0800

> This series of patches add AEAD support to ESP.
> 
> Please don't merge it just yet because they depend on what's
> in the current cryptodev-2.6 tree.  Once that tree has settled
> down I'll ask you to pull it and then these patches can go on
> top of that.

Ok.  I looked over the crypto bits and this one and it looks
really good from here.  Just sent it over when you're ready
for me to pull.
