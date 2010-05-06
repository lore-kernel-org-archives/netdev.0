From: Matt Mackall <mpm@selenic.com>
Subject: Re: [v5 Patch 1/3] netpoll: add generic support for bridge and
 bonding devices
Date: Wed, 05 May 2010 21:05:30 -0500
Message-ID: <1273111530.21962.2753.camel@calx>
References: <20100505081514.5157.83783.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org,
	Andy Gospodarek <gospo@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Jeff Moyer <jmoyer@redhat.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	bonding-devel@lists.sourceforge.net,
	Jay Vosburgh <fubar@us.ibm.com>,
	David Miller <davem@davemloft.net>
To: Amerigo Wang <amwang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100505081514.5157.83783.sendpatchset@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2010-05-05 at 04:11 -0400, Amerigo Wang wrote:
> V5:
> Fix coding style problems pointed by David.

Aside from my concern about the policy of disabling netpoll on
bridges/bonds with only partial netpoll support, I don't have any
remaining issues with this. But I'll leave it to other folks to ack the
underlying driver bits for this series.

-- 
Mathematics is the supreme nostalgia of our time.
