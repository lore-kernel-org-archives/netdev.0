From: Paul Mackerras <paulus@samba.org>
Subject: Re: [RFC] ppp: Bridge Control Protocol
Date: Tue, 2 Mar 2010 14:39:44 +1100
Message-ID: <20100302033944.GL26848@brick.ozlabs.ibm.com>
References: <20100301145915.2ecaac89@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David@mail.vyatta.com, "Miller <davem"@davemloft.net,
	linux-ppp@vger.kernel.org, bridge@linux-foundation.org,
	netdev@vger.kernel.org, dane@aiinet.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:52874 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751231Ab0CBDjt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Mar 2010 22:39:49 -0500
Content-Disposition: inline
In-Reply-To: <20100301145915.2ecaac89@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 01, 2010 at 02:59:15PM -0800, Stephen Hemminger wrote:

> This is a port of an old patch to provide BCP support.
> BCP allows bridging PPP tunnels, it useful to do bridging between
> virtualized environments. Original patch was done by
> Dan Eble but was for 2.4.21.
> 
> Note: still needs testing. Does anyone have hardware to make
> sure this interoperates with other implementations?

Is there a corresponding pppd patch to handle the control protocol?

Paul.
