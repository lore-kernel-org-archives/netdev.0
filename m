From: David Miller <davem@davemloft.net>
Subject: Re: RX problem in ibm_newemac driver
Date: Fri, 13 Mar 2009 13:49:03 -0700 (PDT)
Message-ID: <20090313.134903.259220375.davem@davemloft.net>
References: <49B6FA3B.8030509@embedded-sol.com>
	<1236730894.7086.29.camel@pasglop>
	<49B77CBF.6070005@embedded-sol.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: benh@kernel.crashing.org, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: felix@embedded-sol.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48908
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750949AbZCMUtR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 16:49:17 -0400
In-Reply-To: <49B77CBF.6070005@embedded-sol.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Radensky <felix@embedded-sol.com>
Date: Wed, 11 Mar 2009 10:56:31 +0200

> Benjamin Herrenschmidt wrote:
> > emac: Fix clock control for 405EX and 405EXr chips
> >
> > The EMAC variant in the 405EX and 405EXr chips needs the "440EP" type clock
> > control workaround to avoid lockups of the Rx side during reset.
> >
> > Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
 ...
> This patch fixes a problem for me. Thank you very much for a quick fix.

Patch applied, thanks everyone.
