From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 net-next 0/2] patchset: Support for configurable RSS
 hash key
Date: Thu, 27 Mar 2014 14:53:36 -0400 (EDT)
Message-ID: <20140327.145336.1708122219432567015.davem@davemloft.net>
References: <1395412393.2770.48.camel@deadeye.wl.decadent.org.uk>
	<20140321.152836.1010161671166010422.davem@davemloft.net>
	<BF3270C86E8B1349A26C34E4EC1C44CB2C89CCDD@CMEXMB1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, netdev@vger.kernel.org
To: VenkatKumar.Duvvuru@Emulex.Com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56492 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755487AbaC0Sxi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 14:53:38 -0400
In-Reply-To: <BF3270C86E8B1349A26C34E4EC1C44CB2C89CCDD@CMEXMB1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Venkata Duvvuru <VenkatKumar.Duvvuru@Emulex.Com>
Date: Wed, 26 Mar 2014 09:21:01 +0000

> I don't mind going back to the original approach of adding a new
> hash key operation. Please let me know what you guys think, combined
> operation or a new operation.

Unless Ben has a major objection, I would prefer that we just add a
new hash key interface.

Thanks.
