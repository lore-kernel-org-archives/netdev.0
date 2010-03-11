From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next-2.6 PATCH] ixgbe: convert to use
 netdev_for_each_mc_addr
Date: Thu, 11 Mar 2010 10:18:56 -0800
Message-ID: <1268331536.3136.2.camel@localhost.localdomain>
References: <20100223190505.GA2673@psychotron.redhat.com>
	 <9929d2391002240130p17bbc1acj74e3c8306a3f664@mail.gmail.com>
	 <20100311100809.GB3054@psychotron.lab.eng.brq.redhat.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:12078 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934007Ab0CKSTI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Mar 2010 13:19:08 -0500
In-Reply-To: <20100311100809.GB3054@psychotron.lab.eng.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-03-11 at 03:08 -0700, Jiri Pirko wrote:
> Wed, Feb 24, 2010 at 10:30:54AM CET, jeffrey.t.kirsher@intel.com wrote:
> >On Tue, Feb 23, 2010 at 11:05, Jiri Pirko <jpirko@redhat.com> wrote:
> >>
> >> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
> >> ---
> >>  drivers/net/ixgbe/ixgbe_common.c |   16 +++++++---------
> >>  drivers/net/ixgbe/ixgbe_common.h |    5 ++---
> >>  drivers/net/ixgbe/ixgbe_main.c   |   24 ++----------------------
> >>  drivers/net/ixgbe/ixgbe_type.h   |    3 +--
> >>  4 files changed, 12 insertions(+), 36 deletions(-)
> >>
> >
> >Thanks Jiri, I have added the patch to my queue of ixgbe patches.
> 
> Hi Jeff,
> 
> when do you think this and ixgbevf bits will be merged into net-next-2.6?
> 
> Thanks a lot.
> 
> Jirka

I am waiting for when Dave opens up net-next-2.6 to push this and a
couple other patches.  Usually net-next-2.6 opens up around -rc2 time
frame.

-- 
Cheers,
Jeff

