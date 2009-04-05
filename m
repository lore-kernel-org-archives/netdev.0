From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [RFT][PATCH 0/3] NET: Shutdown fixes for e1000, e1000e and ixgbe
Date: Sun, 5 Apr 2009 12:14:51 +0200
Message-ID: <200904051214.52451.rjw@sisk.pl>
References: <200904042337.31706.rjw@sisk.pl> <9929d2390904050059t4f38428fn145aa615f850dd1f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>,
	Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	Yinghai Lu <yinghai@kernel.org>,
	pm list <linux-pm@lists.linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:39617 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756292AbZDEKOa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Apr 2009 06:14:30 -0400
In-Reply-To: <9929d2390904050059t4f38428fn145aa615f850dd1f@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 05 April 2009, Jeff Kirsher wrote:
> On Sat, Apr 4, 2009 at 2:37 PM, Rafael J. Wysocki <rjw@sisk.pl> wrote:
> > Hi,
> >
> > Commit 3fe7c4c9dca4fbbff92eb61a660690dad7029ec3 (net/igb: Fix kexec with igb
> > (rev. 3)) fixed a kexec problem with igb by making its shutdown routine only
> > put the device into a low power state if the system is going to be powered off.
> >
> > The following three patches make analogous changes to e1000, e1000e and ixgbe.
> >
> 
> Thanks Rafael, I will add these patches to my tree and get them into
> testing on Monday/Tuesday.  If everything looks good after testing, I
> will push them with our other patches.

Great, thanks a lot!

Rafael
