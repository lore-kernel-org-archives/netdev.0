From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v3] net: Do not include padding in TCP GRO checksum
Date: Fri, 22 Nov 2013 10:30:13 +0800
Message-ID: <20131122023013.GA6387@gondor.apana.org.au>
References: <5286F018.8060801@gmail.com>
 <20131116064611.GA12146@gondor.apana.org.au>
 <528A51B6.2040609@intel.com>
 <20131121.133501.272071098922555423.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexander.h.duyck@intel.com, alexander.duyck@gmail.com,
	netdev@vger.kernel.org, edumazet@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:56853 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752146Ab3KVCaV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 21:30:21 -0500
Content-Disposition: inline
In-Reply-To: <20131121.133501.272071098922555423.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 21, 2013 at 01:35:01PM -0500, David Miller wrote:
> 
> I've lost track of this dicussion, Herbert could you post the patches
> I should apply?  I think it was this one and a follow-on simplification
> to the checksum handling?

OK I'll respost.
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
