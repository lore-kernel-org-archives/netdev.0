From: Thomas Wiedemann <Thomas.Wiedemann@iav.de>
Subject: Re: [PATCH net-next-2.6] can/sja1000: driver for PEAK PCAN PCI/PCIe cards
Date: Thu, 29 Sep 2011 11:21:54 +0200
Message-ID: <OFA1D2B7AC.618D2DB3-ONC125791A.0032F517-C125791A.00335871@retarus.de>
References: <4E6F0891.8030600@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: linux@peak-system.com, Netdev@vger.kernel.org,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	SocketCAN Core Mailing List <socketcan-core@lists.berlios.de>
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout01.rmx.de ([217.111.120.9]:47885 "EHLO mailout01.rmx.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755048Ab1I2JV2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Sep 2011 05:21:28 -0400
In-Reply-To: <4E6F0891.8030600@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I got access to another system with a 4 channel card and tested your patch 
(v1) within the Berlios socket-can SVN tree: it worked :)
Thanks!
 
Thomas


Wolfgang Grandegger <wg@grandegger.com> schrieb am 13.09.2011 09:38:57:

> Hi Oliver,
> 
> On 09/12/2011 05:49 PM, Oliver Hartkopp wrote:
> > On 09/09/11 17:20, Wolfgang Grandegger wrote:
> > 
> > 
> >>
> >>> I'll also test your driver on Monday.
> >>
> >> Thanks,
> > 
> > 
> > Hi Wolfgang,
> > 
> > even if i only had my hardware-patched PEAK PCI ExpressCard hardware 
here
> > (which is to be removed in the supported PCI device list due to the 
missing
> > I2C initialization), i successfully tested your driver.
> > 
> > Tested-by: Oliver Hartkopp <socketcan@hartkopp.net>
> 
> Thanks, I have just sent v2.
> 
> > So let's wait for some feedback from Thomas, when he's back to the 
office ;-)
> 
> Yep, some testing on a 4 channel card would be nice.
> 
> Wolfgang.
> 
