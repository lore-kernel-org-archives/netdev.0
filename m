From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 0/3] drivers/net/bfin_mac.c: Neatening
Date: Thu, 29 Jul 2010 16:58:21 -0700
Message-ID: <cover.1280447281.git.joe@perches.com>
Cc: Mike Frysinger <vapier.adi@gmail.com>,
	uclinux-dist-devel <uclinux-dist-devel@blackfin.uclinux.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Michael Hennerich <michael.hennerich@analog.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ho-hum, broken up into pieces just for Mike Frysinger.

Still uncompiled, untested

Joe Perches (3):
  drivers/net/bfin_mac.c: Neatening
  drivers/net/bfin_mac.c: Use pr_<level>, netdev_<level>
  drivers/net/bfin_mac.c: Misc function cleanups, neatening

 drivers/net/bfin_mac.c |  329 ++++++++++++++++++++++++++----------------------
 1 files changed, 176 insertions(+), 153 deletions(-)

-- 
1.7.2.19.g9a302
