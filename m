From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.20 crash in tcp_tso_segment()
Date: Tue, 13 Feb 2007 13:53:48 -0800 (PST)
Message-ID: <20070213.135348.108742593.davem@davemloft.net>
References: <20070213175121.GA27281@gondor.apana.org.au>
	<20070213.123413.35665346.davem@davemloft.net>
	<20070213215158.GA29814@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, maccetta@laurelnetworks.com,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52002
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751313AbXBMVxt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Feb 2007 16:53:49 -0500
In-Reply-To: <20070213215158.GA29814@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 14 Feb 2007 08:51:58 +1100

> On Tue, Feb 13, 2007 at 12:34:13PM -0800, David Miller wrote:
> >
> > I'm kind of challenged for time as I'll be out of town from
> > Wednesday until Sunday, so if someone could cook up the TSO
> > variable of the patch for pre-GSO kernels I'd appreciate it.
> 
> Sure, here is the patch for any kernel prior to 2.6.18.

Thanks a lot Herbert.
