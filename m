From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] net: convert to rcu_dereference_index_check()
Date: Fri, 6 Aug 2010 15:52:36 -0700
Message-ID: <20100806225235.GN2432@linux.vnet.ibm.com>
References: <20100806212607.GA9410@linux.vnet.ibm.com>
 <20100806221520.GA31949@gondor.apana.org.au>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, arnd@arndb.de
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:40902 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751834Ab0HFWwj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Aug 2010 18:52:39 -0400
Content-Disposition: inline
In-Reply-To: <20100806221520.GA31949@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 07, 2010 at 06:15:20AM +0800, Herbert Xu wrote:
> On Fri, Aug 06, 2010 at 02:26:07PM -0700, Paul E. McKenney wrote:
> > Hello, Herbert!
> > 
> > At long last, the following is the final patch blocking acceptance
> > of Arnd's sparse annotations for RCU.  It was itself blocked behind
> > the definition of rcu_dereference_index_check(), which made it to
> > mainline only just today.
> > 
> > Would you be willing to ack this patch so that I can push it to -tip,
> > along with Arnd's work and a bunch of other stuff?
> 
> Sure,
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Thank you, Herbert!!!

							Thanx, Paul
