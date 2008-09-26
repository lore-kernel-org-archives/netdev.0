From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: D945GCLF  intel atom board & r8169 ethernet broken in linux-2.6.27-rc5??
Date: Sat, 27 Sep 2008 00:27:30 +0200
Message-ID: <200809270027.31037.rjw@sisk.pl>
References: <9F6ACAE02B6DD040A1E259977622CFDB03F5BCCB@oslexcp1.eu.tandberg.int> <200809262345.47373.rjw@sisk.pl> <20080926215211.GA26065@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: John Gumb <john.gumb@tandberg.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, "Kok, Auke" <auke-jan.h.kok@intel.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:35322 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751983AbYIZWVw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Sep 2008 18:21:52 -0400
In-Reply-To: <20080926215211.GA26065@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday, 26 of September 2008, Francois Romieu wrote:
> Rafael J. Wysocki <rjw@sisk.pl> :
> > On Wednesday, 24 of September 2008, Francois Romieu wrote:
> [...]
> > > Can you try patches #0001 .. #0008 at
> > > http://userweb.kernel.org/~romieu/r8169/2.6.27-rc6/20080913/ ?
> > 
> > FWIW, these patches make the Ethernet card in the MSI Wind I've been recently
> > testing work much much more reliably. :-)
> 
> The whole series or a part of it ?

I've only tried all of them at once.
