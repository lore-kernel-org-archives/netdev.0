From: Jeff Garzik <jgarzik@pobox.com>
Subject: [BK PATCHES] 2.4.x experimental net driver queue
Date: Wed, 29 Oct 2003 16:20:54 -0500
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20031029212054.GA6445@gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Content-Disposition: inline
List-Id: netdev.vger.kernel.org


BK users:

	bk pull bk://kernel.bkbits.net/jgarzik/net-drivers-2.4-exp

Patch:
ftp://ftp.kernel.org/pub/linux/kernel/people/jgarzik/patchkits/2.4/2.4.22-bk43-netdrvr-exp1.patch.bz2

This will update the following files:

 drivers/net/8139too.c    |   51 +++++++++++++++--------
 drivers/net/Makefile.lib |    1 
 drivers/net/natsemi.c    |  101 +++++++++++++++--------------------------------
 3 files changed, 68 insertions(+), 85 deletions(-)

through these ChangeSets:

<jgarzik@redhat.com> (03/10/14 1.1148.17.2)
   [netdrvr natsemi] backport 2.6 fixes and cleanups

<krishnakumar@naturesoft.net> (03/10/14 1.1148.17.1)
   [netdrvr 8139too] support netif_msg_* interface
