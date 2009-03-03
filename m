From: David Miller <davem@davemloft.net>
Subject: Re: Remaining bits for basic support of LDP
Date: Mon, 02 Mar 2009 22:29:47 -0800 (PST)
Message-ID: <20090302.222947.185552333.davem@davemloft.net>
References: <20090210213712.GB19041@n2100.arm.linux.org.uk>
	<20090210.171348.175525204.davem@davemloft.net>
	<20090301175432.GA24384@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tony@atomide.com, linux-omap@vger.kernel.org,
	netdev@vger.kernel.org
To: linux@arm.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35314
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752681AbZCCGaF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2009 01:30:05 -0500
In-Reply-To: <20090301175432.GA24384@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Date: Sun, 1 Mar 2009 17:54:32 +0000

> On Tue, Feb 10, 2009 at 05:13:48PM -0800, David Miller wrote:
> > From: Russell King - ARM Linux <linux@arm.linux.org.uk>
> > Date: Tue, 10 Feb 2009 21:37:12 +0000
> > 
> > > On Tue, Feb 10, 2009 at 01:02:02PM -0800, Tony Lindgren wrote:
> > > > Yeah, the smsc updates for omap might take a while longer to get going.
> > > > So here's my ack for this smc911x patch:
> > > > 
> > > > Acked-by: Tony Lindgren <tony@atomide.com>
> > > 
> > > Thanks.
> > 
> > Russell if you formally resubmit this with proper changelog, signoffs,
> > and acks I can merge it in quickly via the net-2.6 if you like.
> 
> Sorry for the delay.  Please find patch below.
> 
> OMAP: enable smc911x support for LDP platform
> 
> The following patch enables SMC911x support to work on the OMAP LDP
> board.  Although the SMC911x driver will eventually be obsoleted, the
> smsc911x patches are rather invasive for the -rc kernels.
> 
> Rather than risk destablising smsc911x, this simpler patch is preferred
> to allow the network interface to work.
> 
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
> Acked-by: Tony Lindgren <tony@atomide.com>

Applied, thanks.
