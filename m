From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [RFC Patch 1/3] netpoll: add generic support for bridge and bonding devices
Date: Tue, 23 Mar 2010 08:11:13 -0400
Message-ID: <x49zl1zxmou.fsf@segfault.boston.devel.redhat.com>
References: <20100322082059.4967.63492.sendpatchset@localhost.localdomain>
	<1269297081.3552.19.camel@calx>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Amerigo Wang <amwang@redhat.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	Andy Gospodarek <gospo@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	bonding-devel@lists.sourceforge.net,
	Jay Vosburgh <fubar@us.ibm.com>,
	David Miller <davem@davemloft.net>
To: Matt Mackall <mpm@selenic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1269297081.3552.19.camel@calx> (Matt Mackall's message of "Mon,
	22 Mar 2010 17:31:21 -0500")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Matt Mackall <mpm@selenic.com> writes:

> On Mon, 2010-03-22 at 04:17 -0400, Amerigo Wang wrote:
>> This whole patchset is for adding netpoll support to bridge and bonding
>> devices. I already tested it for bridge, bonding, bridge over bonding,
>> and bonding over bridge. It looks fine now.
>
> Ages ago, Jeff Moyer took a run at this, added him to the cc: on the off
> chance he still cares.

I'll take a look at it in a bit.  For now, here is the link to my
original post on this for Amerigo's reading pleasure:

  http://lkml.indiana.edu/hypermail/linux/kernel/0507.0/0206.html

Cheers,
Jeff
