From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] remove extra memset from dn_fib_check_nh
Date: Sat, 1 Dec 2007 23:31:30 +1100
Message-ID: <20071201123130.GB15910@gondor.apana.org.au>
References: <20071130155401.GA10051@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: devel@openvz.org, netdev@vger.kernel.org, davem@davemloft.net
To: "Denis V. Lunev" <den@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3204 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751369AbXLAMbe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2007 07:31:34 -0500
Content-Disposition: inline
In-Reply-To: <20071130155401.GA10051@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 30, 2007 at 06:54:01PM +0300, Denis V. Lunev wrote:
> [PATCH] remove extra memset from dn_fib_check_nh
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

Applied to net-2.6.25.  Thanks Denis!
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
