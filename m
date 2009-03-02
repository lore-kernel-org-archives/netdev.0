From: David Miller <davem@davemloft.net>
Subject: Re: Vlan interface nuisance
Date: Mon, 02 Mar 2009 01:57:52 -0800 (PST)
Message-ID: <20090302.015752.87125075.davem@davemloft.net>
References: <20090302073912.GA17328@gondor.apana.org.au>
	<49ABAAC7.6070806@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, stephen.hemminger@vyatta.com,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46046
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756483AbZCBJ6I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2009 04:58:08 -0500
In-Reply-To: <49ABAAC7.6070806@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 02 Mar 2009 10:45:43 +0100

> Herbert Xu wrote:
> > Stephen Hemminger <stephen.hemminger@vyatta.com> wrote:
> >>> In any case, ip(8) allows you to set the name to whatever you
> >>> want at creation time.  So for those nostalgics you can still
> >>> use ethX.Y through ip.
> >>>   
> >> Yes but their is no indication as to which interface was just created.
> > You should be able to set the name at creation time.
> > The default is only used if you didn't specify an explicit name.
> 
> Indeed. The kernel also sends notifications, so iproute could print
> the generated name if none was specified.

I considered this issue closed 6 emails ago.

I don't know why Stephen keeps persisting. :-)
