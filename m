From: Peter Mueller <pmueller@sidestep.com>
Subject: RE: [PATCH] Convert ipvs to use seq_file.
Date: Mon, 15 Sep 2003 14:56:59 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <37328159548B4242A34141B1A69CDB73031BAAAE@exchange.sidestep.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "'LinuxVirtualServer.org users mailing list.'"
	 <lvs-users@LinuxVirtualServer.org>,
   "David S. Miller" <davem@redhat.com>,
   "'Stephen Hemminger'" <shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello Stephen,

> P.s: how come there is no MAINTAINER listed for IPVS?

Wensong Zhang is the maintainer; where did you expect to see a maintainer
listed at?  The LVS-developers that seem to be most active are:

Wensong Zhang
Julian Atanasaov
Simon Horman ('Horms')
Alexandre Cassen
Roberto Nibali ('Ratz')
Joseph Mack

AFAIK Redhat takes the LVS-source and patches it up at their end for
Pirahna, so patches should probably not go to RH.

Hope it helps,

Peter
