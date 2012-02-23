From: Jason White <jason@jasonjgw.net>
Subject: Re: [openadsl-users] [Bug 42809] New: kernel panic when receiving an
 ipsec packet
Date: Thu, 23 Feb 2012 12:46:14 +1100
Message-ID: <20120223014614.GA10657@jdc.jasonjgw.net>
References: <bug-42809-100@https.bugzilla.kernel.org/>
 <20120222092056.5fca788b@nehalam.linuxnetplumber.net>
 <4F4528CE.7080702@linuxsystems.it>
 <4F458F82.3060808@linuxsystems.it>
 <1329961083.15610.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: =?iso-8859-1?Q?Niccol=F2?= Belli <darkbasic@linuxsystems.it>,
	660804@bugs.debian.org, openadsl-devel@lists.sourceforge.net,
	Mailing List <netdev@vger.kernel.org>, support@traverse.com.au,
	Stephen Hemminger <shemminger@vyatta.com>,
	support@rocksolidelectronics.com
To: openadsl users list <openadsl-users@lists.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from jdc.jasonjgw.net ([59.167.198.218]:53972 "EHLO jdc.jasonjgw.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751134Ab2BWByL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Feb 2012 20:54:11 -0500
Content-Disposition: inline
In-Reply-To: <1329961083.15610.2.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
 
> Which driver handles this Traverse Solos card ?

solos_pci, which also requires the atm module.

(I'm just trying to help here; I'm not affected by the bug.)
