From: David Miller <davem@davemloft.net>
Subject: Re: [VLAN]: translate IF_OPER_DORMANT to netif_dormant_on()
Date: Sun, 09 Jul 2006 11:48:27 -0700 (PDT)
Message-ID: <20060709.114827.63031023.davem@davemloft.net>
References: <44AE2FCC.6020207@trash.net>
	<20060707143314.67bf07ff@dxpl.pdx.osdl.net>
	<200607091049.31628.stefan@loplof.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, kaber@trash.net, greearb@candelatech.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:41950
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1161046AbWGISrz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Jul 2006 14:47:55 -0400
To: stefan@loplof.de
In-Reply-To: <200607091049.31628.stefan@loplof.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stefan Rompf <stefan@loplof.de>
Date: Sun, 9 Jul 2006 10:49:31 +0200

> Am Freitag, 7. Juli 2006 23:33 schrieb Stephen Hemminger:
> 
> > Not really. The flag code last major change was to do the dormant
> > stuff that HDLC wanted.
> 
> ... and where the maintainer doesn't seem to care to use it now that the 
> infrastructure is there. Sigh.

Yes, this is very unfortunate.  They made the loudest noise about
wanting the change, yet they aren't even responsible enough to submit
the HDLC patches necessary to make use of it.  This was apparently
needed to fix HDLC, so where's the followup?

This is why the HDLC "maintainers" shouldn't be surprised if we flat
out ignore them the next time they complain about anything.  They
have proven that they are pure whiners.
