From: David Miller <davem@davemloft.net>
Subject: Re: Regression in bonding between 2.6.26.8 and 2.6.27.6 - bisected
 - twice
Date: Mon, 16 Mar 2009 13:35:59 -0700 (PDT)
Message-ID: <20090316.133559.173588446.davem@davemloft.net>
References: <20090313.161217.52045656.davem@davemloft.net>
	<8799.1236986836@death.nxdomain.ibm.com>
	<49BEB7DE.9000201@krogh.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jgarzik@redhat.com, aowi@novozymes.com
To: jesper@krogh.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54587
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756878AbZCPUgO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2009 16:36:14 -0400
In-Reply-To: <49BEB7DE.9000201@krogh.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Krogh <jesper@krogh.cc>
Date: Mon, 16 Mar 2009 21:34:38 +0100

> Jay Vosburgh wrote:
> > 	The above fragment isn't needed for mainline, only for -stable.
> > 
> 
> Did you sent it off to the stable kernel maintainers?

The fix has to go into Linus's tree first.

I haven't integrated Jay's changes yet.
