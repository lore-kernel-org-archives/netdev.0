From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: ipv6: INFO: possible circular locking dependency detected --
	2.6.29-rc3
Date: Fri, 30 Jan 2009 18:05:56 +1100
Message-ID: <20090130070556.GA4977@gondor.apana.org.au>
References: <20090129124328.GA21638@think>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: arrow.ebd@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:53392 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751931AbZA3HGA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2009 02:06:00 -0500
Content-Disposition: inline
In-Reply-To: <20090129124328.GA21638@think>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

arrow.ebd@gmail.com wrote:
> 
>        Here is some error message when I starting gw6c, but work fine
> after try again.

Please see

http://bugzilla.kernel.org/show_bug.cgi?id=12515
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
