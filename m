From: Jeff Garzik <jeff@garzik.org>
Subject: Re: wireless (was Re: 2.6.18 -mm merge plans)
Date: Mon, 5 Jun 2006 08:52:35 -0400
Message-ID: <20060605125235.GB6066@havoc.gtf.org>
References: <20060604135011.decdc7c9.akpm@osdl.org> <20060605010636.GB17361@havoc.gtf.org> <20060605085451.GA26766@infradead.org> <20060605123304.GA6066@havoc.gtf.org> <1149511707.3111.57.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>,
	Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:10406 "EHLO havoc.gtf.org")
	by vger.kernel.org with ESMTP id S1751085AbWFEMx3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2006 08:53:29 -0400
To: Arjan van de Ven <arjan@infradead.org>
Content-Disposition: inline
In-Reply-To: <1149511707.3111.57.camel@laptopd505.fenrus.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 05, 2006 at 02:48:27PM +0200, Arjan van de Ven wrote:
> Why is it a good thing you are blocking this driver? Do you have ANY
> indication AT ALL that there is anything fishy about it?

Yes.


> Paying attention to proper reverse engineering is good. Being
> overzealous is not.

Being overzealous about merging drivers without first checking the legal
ramifications is a good way to torpedo Linux.

Far too many people have a careless "U.S.A. laws suck, merge it anyway"
attitude.

	Jeff



