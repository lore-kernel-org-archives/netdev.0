From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] udp: net-2.6.22 build fix
Date: Wed, 07 Mar 2007 14:39:57 -0800 (PST)
Message-ID: <20070307.143957.59653232.davem@davemloft.net>
References: <20070307134743.42e3b5c7@freekitty>
	<20070307215148.GA30424@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58314
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S2992692AbXCGWj7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2007 17:39:59 -0500
In-Reply-To: <20070307215148.GA30424@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 8 Mar 2007 08:51:48 +1100

> Perhaps we can recode these macros so that they always get
> compiled-checked?

Yes, we really should.
