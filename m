From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [net-next PATCH 0/3] Introduce the Intel 82599 10 Gigabit Network
 	Adapter family
Date: Sun, 1 Mar 2009 10:34:39 -0800 (Pacific Standard Time)
Message-ID: <Pine.WNT.4.64.0903011032310.28208@ppwaskie-MOBL2.amr.corp.intel.com>
References: <20090228013916.22664.54781.stgit@lost.foo-projects.org>
 <20090301.002515.46575653.davem@davemloft.net>
 <9929d2390903010230k7ed97b3du45e37c51ec742d37@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:60085 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752725AbZCASen (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Mar 2009 13:34:43 -0500
In-Reply-To: <9929d2390903010230k7ed97b3du45e37c51ec742d37@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 1 Mar 2009, Jeff Kirsher wrote:

> On Sun, Mar 1, 2009 at 12:25 AM, David Miller <davem@davemloft.net> wrote:
> > From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > Date: Fri, 27 Feb 2009 17:44:16 -0800
> >
> >> The following series implements basic support for the new Intel 82599 10 Gigabit Network adapter.  Contained in this patchset is:
> >>
> >>       1) Hardware specific code to initialize the 82599 device
> >>       2) Include Data Center Bridging support for 82599
> >>       3) Add the current device ID's for 82599, including a fully pluggable 1G/10G SFP+ NIC, and a KX/KX4 mezzanine card
> >
> > All applied.
> >
> > I look forward to seeing you guys followup on the I2C usage
> > stuff Ben pointed out :-)
> > --
> 
> Thanks Dave.
> 
> I know that PJ is actively working with Ben to see how we can
> implement the in kernel I2C interface into the driver.

Yes, Ben has helped quite a bit pointing me in the right direction.  I'll 
be cleaning up both the 82599 I2C usage, and I'll try and clean up the 
existing 82598 I2C usage at the same time.

Cheers,
-PJ
