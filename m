From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCHSET 0/4] PKT_SCHED: More classifier cleanups
Date: Fri, 29 Oct 2004 16:06:12 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041029140612.GO12289@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, hadi@cyberus.ca
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dave,

Cleans up route,rsvp,tcindex, and u32 classifier to
use the generic classifier routines.

All trivial changes not changing any behaviour.

Relative to patchset "Generic classifier routines / cls_fw cleanup"

Remaining on the road to clean classifier statistics:
 - transform action to generic statistics
 - transform policer to generic statistics
 - iproute2 patch for those
 - remove old estimator and copy stats routines

Cheers
