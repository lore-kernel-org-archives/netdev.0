From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH resend 2.6.25 11/12][BNX2X]: update version
Date: Tue, 26 Feb 2008 18:41:37 -0800 (PST)
Message-ID: <20080226.184137.196667426.davem@davemloft.net>
References: <1203935591.8232.215.camel@lb-tlvb-eliezer.il.broadcom.com>
	<20080226.180913.119140892.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: eliezert@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35470
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752457AbYB0Ckw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2008 21:40:52 -0500
In-Reply-To: <20080226.180913.119140892.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Tue, 26 Feb 2008 18:09:13 -0800 (PST)

> From: "Eliezer Tamir" <eliezert@broadcom.com>
> Date: Mon, 25 Feb 2008 12:33:11 +0200
> 
> > [BNX2X]: update version
> > 
> > Signed-off-by: Eliezer Tamir <eliezert@broadcom.com>
> 
> Please resubmit this with the reworked versions of the
> changes I did not apply, thanks.

Unfortunately, I had to revert everything.

If I don't apply patch 3, then there are references to things
added by that change in subsequent patches and the build breaks.

Please resubmit this whole series with better changelog messages
and also add a change to remove the CVS tag thing.

Thanks.
