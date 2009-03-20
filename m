From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2: Use request_firmware()
Date: Fri, 20 Mar 2009 15:50:30 -0700 (PDT)
Message-ID: <20090320.155030.164080684.davem@davemloft.net>
References: <1237501747.4126.10.camel@deadeye.i.decadent.org.uk>
	<1237503884.16140.23.camel@HP1>
	<20090319232541.GA19262@wavehammer.waldi.eu.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, ben@decadent.org.uk, davem@davemloft.org,
	netdev@vger.kernel.org
To: waldi@debian.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37081
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754681AbZCTWun (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2009 18:50:43 -0400
In-Reply-To: <20090319232541.GA19262@wavehammer.waldi.eu.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bastian Blank <waldi@debian.org>
Date: Fri, 20 Mar 2009 00:25:41 +0100

> On Thu, Mar 19, 2009 at 04:04:44PM -0700, Michael Chan wrote:
> > Thanks Ben and Bastian.  I will review this and test it out.  I think I
> > will add some logic to check firmware versions to guarantee some level
> > of compatibility.
> 
> The firmware version is coded into the filenames.

Michael and co. please do not make such a big deal about
this.

This patch is perfectly fine as-is.
