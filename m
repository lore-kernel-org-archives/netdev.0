From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch 0/4] 2.6.5-rc2-mm5 - r8169 queue
Date: Mon, 29 Mar 2004 19:36:04 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040329193604.A4744@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

There are a few (hopefully) harmless things in the local queue that I'd
appreciate to go mainline before the second round of r8169 changes.
The patches are diffed against 2.6.5-rc2-mm5 and should apply cleanly to
the -netdev serie.

- r8169-ethtool-introduction.patch
- r8169-missing-static.patch
- r8169-maintainer.patch
- r8169-dma-api-update.patch

Despite its limited performance, #3/4 does not work too bad.

The patch I provided today on l-k includes a small change which could
improve performance. If Daniel Egger is satisfied with it, a patch for
the adequate changes will follow.

--
Ueimor
