From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: 2.6.18-rc3-mm2 (+ hotfixes): GPF related to skge on suspend
Date: Sat, 12 Aug 2006 16:32:19 +0200
Message-ID: <200608121632.19070.rjw@sisk.pl>
References: <200608121207.42268.rjw@sisk.pl> <20060812052853.f9e5d648.akpm@osdl.org> <44DDDA2F.4080404@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, LKML <linux-kernel@vger.kernel.org>,
	Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:22158 "EHLO ogre.sisk.pl")
	by vger.kernel.org with ESMTP id S964835AbWHLOdB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Aug 2006 10:33:01 -0400
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <44DDDA2F.4080404@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 12 August 2006 15:39, Jeff Garzik wrote:
> Andrew Morton wrote:
> > It would be good if you could poke around in gdb, work out exactly which
> > statement it's oopsing at, please.
> 
> I'm also interested to know if the problem goes away when you disable 
> preempt...

That will take some time to test. :-)

Rafael
