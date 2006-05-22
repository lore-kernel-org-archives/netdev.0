From: Ravikiran G Thirumalai <kiran@scalex86.org>
Subject: [CFT] CONFIG_IP_ROUTE_MULTIPATH_CACHED [was Re: [PATCH] Disable multipath cache routing ]
Date: Sun, 21 May 2006 21:55:21 -0700
Message-ID: <20060522045521.GA4786@localhost.localdomain>
References: <446ED597.20300@calsoftinc.com> <446EE440.8000808@calsoftinc.com> <20060520205145.GB32010@taniwha.stupidest.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pravin b shelar <pravin.shelar@calsoftinc.com>,
	Suresh Bhogavilli <sbhogavilli@verisign.com>,
	Julian Anastasov <ja@ssi.bg>, Ilia Sotnikov <hostcc@gmail.com>,
	netdev@vger.kernel.org, Einar Lueck <elueck@de.ibm.com>,
	lkml@einar-lueck.de, Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server99.tchmachines.com ([72.9.230.178]:50386 "EHLO
	server99.tchmachines.com") by vger.kernel.org with ESMTP
	id S1751181AbWEVEyH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 May 2006 00:54:07 -0400
To: Chris Wedgwood <cw@f00f.org>
Content-Disposition: inline
In-Reply-To: <20060520205145.GB32010@taniwha.stupidest.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, May 20, 2006 at 01:51:45PM -0700, Chris Wedgwood wrote:
> ...
> Anyhow, the code as-is hasn't been maintained for a long time except
> for a few minor blips (I'm using hg's annotate to find those and have
> included those people on the cc' list as presumably there are using
> these features and might have useful input).

We are interested in keeping CONFIG_IP_ROUTE_MULTIPATH_CACHED,
as this enables us to do node aware multipathing
	http://lkml.org/lkml/2006/3/22/13
Hence, we are also interested in stabilizing MULTIPATH_CACHED.  Please send
bug reports with the test case scenario to myself and Pravin at 
kiran@scalex86.org and pravin.shelar@calsoftinc.com

Thanks,
Kiran
