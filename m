From: Russell Stuart <russell-tcatm@stuart.id.au>
Subject: Re: [PATCH
	REPOST	1/2]	NET:	Accurate	packet	scheduling	for	ATM/ADSL (kernel)
Date: Sat, 20 Jan 2007 13:25:17 +1000
Message-ID: <1169263517.11507.14.camel@ras>
References: <1161041677.6247.1.camel@ras.pc.brisbane.lube>
	 <1161090444.5555.13.camel@jzny2>  <45378DE3.8080700@trash.net>
	 <1161602527.5502.155.camel@ras.pc.stuart.local>
	 <453CB801.4010902@trash.net>
	 <1161640444.5502.214.camel@ras.pc.stuart.local> <453E3CFC.80007@trash.net>
	 <1161733596.3829.91.camel@ras.pc.brisbane.lube>
	 <456ED79E.2070707@trash.net> <1169075223.7560.15.camel@ras>
	 <45AEF219.2060304@trash.net> <1169100970.21535.18.camel@ras>
	 <45AF5C02.1010005@trash.net> <1169176280.1118.8.camel@ras>
	 <45B0B744.7070800@trash.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 58.105.229.78.optusnet.com.au ([58.105.229.78]:36729 "EHLO
	adsl-kenny.stuart.id.au" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S965094AbXATD2t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jan 2007 22:28:49 -0500
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <45B0B744.7070800@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-01-19 at 13:19 +0100, Patrick McHardy wrote:
> Russell Stuart wrote:
> > I thought that some degree of compatibility was 
> > expected.  At the very least the newest version 
> > of "tc" must work on _any_ kernel as least as 
> > well as the version it replaces did.
> > 
> > I also though newer kernels should work older
> > version of iproute2, albeit without the features
> > added in the newer versions.
> > 
> > Are you saying this is not so?
> 
> No, thats exactly what I'm saying.

I don't understand - too many negates here 
without parens.  Are you saying:

a.  Backward / Forward compatibility between the kernel
    and its user space tools isn't an issue, or

b.  There is no compatibility problem.

