From: Stefan Rompf <stefan@loplof.de>
Subject: Re: [VLAN]: translate IF_OPER_DORMANT to netif_dormant_on()
Date: Sun, 9 Jul 2006 10:49:31 +0200
Message-ID: <200607091049.31628.stefan@loplof.de>
References: <200603211829.k2LITMNR029085@hera.kernel.org> <44AE2FCC.6020207@trash.net> <20060707143314.67bf07ff@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Ben Greear <greearb@candelatech.com>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from natlemon.rzone.de ([81.169.145.170]:33723 "EHLO
	natlemon.rzone.de") by vger.kernel.org with ESMTP id S932420AbWGIIri
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Jul 2006 04:47:38 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060707143314.67bf07ff@dxpl.pdx.osdl.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Freitag, 7. Juli 2006 23:33 schrieb Stephen Hemminger:

> Not really. The flag code last major change was to do the dormant
> stuff that HDLC wanted.

... and where the maintainer doesn't seem to care to use it now that the 
infrastructure is there. Sigh.

> IMHO VLAN device's should mirror the state of the underlying physical
> device.
>
> I can't really follow the thread well. What is broken?

The thread is still quite short and describes the problem, look at 
http://marc.theaimsgroup.com/?t=115200782600004&r=1&w=2

Stefan
