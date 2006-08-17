From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: [RFC][PATCH 0/8] [RFC][PATCH 0/8] Removal of old code
Date: Thu, 17 Aug 2006 04:48:19 +0000
Message-ID: <20060817044819.0.oIvGvh2320.2316.michal@euridica.enternet.net.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, jes@trained-monkey.org,
	netdev@vger.kernel.org, davem@davemloft.net, tglx@linutronix.de,
	Eric.Moore@lsil.com, linux-scsi@vger.kernel.org, mikep@linuxtr.net,
	xfs-masters@oss.sgi.com, nathans@sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932430AbWHQEsJ@vger.kernel.org>
To: akpm@osdl.org
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The patches have been tested with allmodconfig and allmodconfig.

drivers/message/fusion/linux_compat.h |    9 -----
drivers/mtd/nand/au1550nd.c           |   11 ------
drivers/net/acenic.c                  |    4 --
drivers/net/irda/vlsi_ir.h            |   17 ---------
drivers/net/tokenring/lanstreamer.c   |   59 ----------------------------------
drivers/net/tokenring/lanstreamer.h   |   12 ------
drivers/net/typhoon.c                 |    4 --
fs/xfs/xfs_dmapi.h                    |   17 ---------
8 files changed, 1 insertion(+), 132 deletions(-)

Regards,
Michal

-- 
Michal K. K. Piotrowski
LTG - Linux Testers Group
(http://www.stardust.webpages.pl/ltg/wiki/)
