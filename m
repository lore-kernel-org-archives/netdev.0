From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: raw sockets ignore IP_HDRINCL data
Date: Mon, 4 Jun 2007 09:59:02 +1000
Message-ID: <20070603235902.GA26830@gondor.apana.org.au>
References: <E1HuRS1-0002aE-00@gondolin.me.apana.org.au> <1180911127.5956.64.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Mick McCreath <mick_mccreath@au.securecomputing.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2450 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750725AbXFDAPE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Jun 2007 20:15:04 -0400
Content-Disposition: inline
In-Reply-To: <1180911127.5956.64.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 04, 2007 at 08:52:07AM +1000, Mick McCreath wrote:
> 
> Which traceroute are you using??
> 
> I am using version 1.4a12 by Van Jacobson downloaded from Lawrence
> Berkeley Labs.

The one from Debian which is based on the same source.  Hmm, it
looks like I came to the same conclusion that you did and added
a patch to it five years ago to get it to bind the interface :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
