From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Fri, 28 Apr 2006 21:29:32 +0400
Message-ID: <20060428172932.GB16916@2ka.mipt.ru>
References: <54AD0F12E08D1541B826BE97C98F99F143B0F3@NT-SJCA-0751.brcm.ad.broadcom.com> <20060428101833.2f0d6ae8@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Caitlin Bestler <caitlinb@broadcom.com>,
	"David S. Miller" <davem@davemloft.net>, kelly@au1.ibm.com,
	rusty@rustcorp.com.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:4281 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751406AbWD1RaR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2006 13:30:17 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060428101833.2f0d6ae8@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 28, 2006 at 10:18:33AM -0700, Stephen Hemminger (shemminger@osdl.org) wrote:
> Please just use existing AIO interface.  We don't need another
> interface. The number of interfaces increases the exposed bug
> surface geometrically.  Which means for each new interface, it
> means testing and fixing bugs in every possible usage.

Networking AIO? Like [1] :)
That would be really good.

1. http://tservice.net.ru/~s0mbre/old/?section=projects&item=naio

-- 
	Evgeniy Polyakov
