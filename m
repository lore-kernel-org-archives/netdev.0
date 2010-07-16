From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] Remove REDWOOD_[456] config options and
 conditional code
Date: Fri, 16 Jul 2010 13:45:58 -0700 (PDT)
Message-ID: <20100716.134558.235673512.davem@davemloft.net>
References: <cover.1279282865.git.qy03fugy@stud.informatik.uni-erlangen.de>
	<ca1bb25d203618c3548748f5efb6f125a96c89e0.1279282865.git.qy03fugy@stud.informatik.uni-erlangen.de>
	<20100716142055.GA11736@zod.rchland.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: qy03fugy@stud.informatik.uni-erlangen.de, miltonm@bga.com,
	mporter@kernel.crashing.org, benh@kernel.crashing.org,
	paulus@samba.org, solomon@linux-wlan.com, dwmw2@infradead.org,
	vapier@gentoo.org, jkosina@suse.cz, Artem.Bityutskiy@nokia.com,
	linux@kbdbabel.org, randy.dunlap@oracle.com, john.linn@xilinx.com,
	florian@openwrt.org, nico@fluxnic.net, joe@perches.com,
	ladis@linux-mips.org, davidb@quicinc.com, linuxppc-dev@ozlabs.org,
	linux-kernel@vger.kernel.org, linux-mtd@lists.infradead.org,
	netdev@vger.kernel.org, vamos-dev@i4.informatik.uni-erlangen.de
To: jwboyer@linux.vnet.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100716142055.GA11736@zod.rchland.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Josh Boyer <jwboyer@linux.vnet.ibm.com>
Date: Fri, 16 Jul 2010 10:20:55 -0400

> On Fri, Jul 16, 2010 at 02:29:02PM +0200, Christian Dietrich wrote:
>>The config options for REDWOOD_[456] were commented out in the powerpc
>>Kconfig. The ifdefs referencing this options therefore are dead and all
>>references to this can be removed (Also dependencies in other KConfig
>>files).
>>
>>Signed-off-by: Christian Dietrich <qy03fugy@stud.informatik.uni-erlangen.de>
>>Signed-off-by: Christoph Egger <siccegge@cs.fau.de>
> 
> This seems fine with me.
> 
> The only question is which tree it coms through.  I'm happy to take it
> in via mine if the netdev and MTD people are fine with that.  Otherwise,
> my ack is below.
> 
> Acked-by: Josh Boyer <jwboyer@linux.vnet.ibm.com>

Please take it:

Acked-by: David S. Miller <davem@davemloft.net>
