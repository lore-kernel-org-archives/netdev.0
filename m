From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] net: convert to rcu_dereference_index_check()
Date: Sat, 7 Aug 2010 06:15:20 +0800
Message-ID: <20100806221520.GA31949@gondor.apana.org.au>
References: <20100806212607.GA9410@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, arnd@arndb.de
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:40769 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934096Ab0HFWPY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Aug 2010 18:15:24 -0400
Content-Disposition: inline
In-Reply-To: <20100806212607.GA9410@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 06, 2010 at 02:26:07PM -0700, Paul E. McKenney wrote:
> Hello, Herbert!
> 
> At long last, the following is the final patch blocking acceptance
> of Arnd's sparse annotations for RCU.  It was itself blocked behind
> the definition of rcu_dereference_index_check(), which made it to
> mainline only just today.
> 
> Would you be willing to ack this patch so that I can push it to -tip,
> along with Arnd's work and a bunch of other stuff?

Sure,

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
