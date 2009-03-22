From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] snap: use const for descirptor
Date: Sat, 21 Mar 2009 19:08:26 -0700 (PDT)
Message-ID: <20090321.190826.117162165.davem@davemloft.net>
References: <20090320084314.5761b1d9@nehalam>
	<20090320181625.GP30407@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: acme@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46160
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752088AbZCVCIj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2009 22:08:39 -0400
In-Reply-To: <20090320181625.GP30407@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Fri, 20 Mar 2009 15:16:25 -0300

> Em Fri, Mar 20, 2009 at 08:43:14AM -0700, Stephen Hemminger escreveu:
> > Protocols should be able to use constant value for the descriptor.
> > Minor whitespace cleanup as well
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> Looks ok, thanks
> 
> 
> Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

Applied.
