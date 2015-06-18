From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net 1/2] bridge: multicast: restore router configuration
 on port link down/up
Date: Thu, 18 Jun 2015 11:34:44 +0800
Message-ID: <20150618033444.GA27370@gondor.apana.org.au>
References: <1434540511-648-1-git-send-email-nikolay@cumulusnetworks.com>
 <1434540511-648-2-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	davem@davemloft.net, sashok@cumulusnetworks.com
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:44433 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751462AbbFRDew (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 23:34:52 -0400
Content-Disposition: inline
In-Reply-To: <1434540511-648-2-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 17, 2015 at 04:28:30AM -0700, Nikolay Aleksandrov wrote:
> From: Satish Ashok <sashok@cumulusnetworks.com>
> 
> When a port goes through a link down/up the multicast router configuration
> is not restored.
> 
> Signed-off-by: Satish Ashok <sashok@cumulusnetworks.com>
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> Fixes: 0909e11758bd ("bridge: Add multicast_router sysfs entries")

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
