From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rds: Error on offset mismatch if not loopback
Date: Fri, 21 Sep 2012 13:20:45 -0400 (EDT)
Message-ID: <20120921.132045.951559071646755065.davem@davemloft.net>
References: <20120920071134.GF14393@linux-tkdk.sfcn.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, venkat.x.venkatsubra@oracle.com,
	netdev@vger.kernel.org
To: jjolly@suse.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120920071134.GF14393@linux-tkdk.sfcn.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Jolly <jjolly@suse.com>
Date: Thu, 20 Sep 2012 01:11:34 -0600

> Attempting an rds connection from the IP address of an IPoIB interface
> to itself causes a kernel panic due to a BUG_ON() being triggered. Making
> the test less strict allows rds-ping to work without crashing the machine.
> 
> A local unprivileged user could use this flaw to crash the sytem.

Please read Documentation/SubmittingPatches to learn how to properly
submit a change, in particular your patch submission was missing a
proper signoff.

Thanks.
