From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH/RFC] net: Add __napi_sycnhronize() to sync with
	napi	poll
Date: Wed, 17 Oct 2007 13:24:41 +1000
Message-ID: <1192591481.11899.134.camel@pasglop>
References: <1192513792.19073.23.camel@pasglop>
	 <20071016115318.0fc36af3@freepuppy.rosehill>
	 <1192589522.11899.130.camel@pasglop>  <47157EA4.1000500@garzik.org>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Roland Dreier <rdreier@cisco.com>,
	linuxppc-dev list <linuxppc-dev@ozlabs.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:57416 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756200AbXJQDZA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Oct 2007 23:25:00 -0400
In-Reply-To: <47157EA4.1000500@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

\
> > Note: unfortunately, Jeff already picked up the EMAC patch without
> > waiting for this to be sorted out (oops...). So if you agree with
> > this patch, it would be nice to have it go in quickly or maybe via
> > Jeff's tree to avoid breakage ? Not terribly important tho.
> 
> 
> Sorry, I thought that was the way everybody was headed.  With the driver 
> broken /anyway/, I just sorta threw it into the pile of fixes.
> 
> It's upstream now, so let me know if you want to revert or move forward 
> from here...

Let's just move forward. I can always re-fix the driver :-)

Ben.


