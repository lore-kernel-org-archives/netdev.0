From: Ralf Baechle DL5RB <ralf@linux-mips.org>
Subject: [PATCH 0/9] Testers needed for ham radio patches
Date: Sun, 30 Jan 2005 21:20:07 +0000
Message-ID: <20050130212007.GA6073__14773.7122177661$1107121578$gmane$org@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
Resent-Message-Id: <200501302140.j0ULeFPX006985@dea.linux-mips.net>
To: linux-hams@vger.kernel.org
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I've cooked a series of patches that convert most of the ham radio drivers
and core code to convert them to use the netdev_priv() macro which was
introduced a while ago.  Lacking all the hardware for testing in the hope
for testers.  I left out the SCC and DMASCC drivers; they're looking too
scarry to touch without having hardware.

The patches are compile tested and I consider them low risk, so probably
safe to merged right away if you'd like.

73 de DL5RB op Ralf
