From: David Miller <davem@davemloft.net>
Subject: [README] net-next has been merged
Date: Mon, 21 May 2012 17:09:39 -0400 (EDT)
Message-ID: <20120521.170939.1673415470771353481.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netfilter-devel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Linus has pulled in all of the net-next changes, and I have
subsequently fast-forwarded both 'net' and 'net-next' to
Linus's tree.

All work at this time should be bug fixes and should be arranged
against 'net'.  'net-next' will be frozen and untouched until
some time after the merge window closes, and no development should
occur against it.

I am rejecting all patches in patchwork which implement new features,
perform cleanups, or otherwise are inappropriate at this time.  You
must resubmit them when the net-next tree opens back up.

There is one exception waiting in the wings, there is one netfilter
pull remaining from Pedro for the merge window and I told him that
this is OK.
