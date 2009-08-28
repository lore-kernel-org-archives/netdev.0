From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [linux-pm] power draw depending on PHY speed
Date: Fri, 28 Aug 2009 21:03:59 +0200
Message-ID: <200908282103.59159.rjw@sisk.pl>
References: <76FA3B279DD9DA48896E2B40494495720368E449@USA7061MS02.na.xerox.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-pm@lists.linux-foundation.org, martyleisner@yahoo.com,
	NetDEV list <netdev@vger.kernel.org>
To: "Leisner, Martin" <Martin.Leisner@xerox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:44619 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752000AbZH1TDI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Aug 2009 15:03:08 -0400
In-Reply-To: <76FA3B279DD9DA48896E2B40494495720368E449@USA7061MS02.na.xerox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 28 August 2009, Leisner, Martin wrote:
> While doing some current probe measurements (i.e. to measure the effects
> of NAP and frequency scaling with a freescale processor) I noticed some
> very
> significant differents if we ran on 100Mbit of 1000Mbit ethernet.
> 
> The hardware guys like at their data sheets and agreed.
> 
> Does anyone "drop ethernet speed" to save power?
> (when a system is idle, is isn't necessary to run 1G ethernet).

I don't know, really.  This is a netdev question IMO (CC added).

> When a system has WOL capability, what speed does it run at when the
> system is sleeping?

That's a very good question.  I bet that depends on the NIC in question, at
least I'm not sure if any spec regulates it.

Thanks,
Rafael
