From: Jeff Garzik <jgarzik@pobox.com>
Subject: [BK PATCHES] 2.4.x experimental net driver updates
Date: Tue, 14 Oct 2003 15:32:14 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031014193214.GA23154@gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


BK users:

	bk pull bk://kernel.bkbits.net/jgarzik/net-drivers-2.4-exp

GNU diff:
ftp://ftp.kernel.org/pub/linux/kernel/people/jgarzik/patchkits/2.4/2.4.22-bk34-netdrvr-exp1.patch.bz2

This will update the following files:

 drivers/net/8139too.c    |   51 +++++++++++++++--------
 drivers/net/Makefile.lib |    1 
 drivers/net/natsemi.c    |  101 +++++++++++++++--------------------------------
 3 files changed, 68 insertions(+), 85 deletions(-)

through these ChangeSets:

<jgarzik@redhat.com> (03/10/14 1.1191)
   [netdrvr natsemi] backport 2.6 fixes and cleanups

<krishnakumar@naturesoft.net> (03/10/14 1.1190)
   [netdrvr 8139too] support netif_msg_* interface
