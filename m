From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [GIT PULL net-2.6] vhost-net: fix range checking
Date: Mon, 20 Sep 2010 19:42:22 +0200
Message-ID: <20100920174222.GA30510@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, virtualization@lists.osdl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David,
The following tree includes a bugfix for vhost-net.
It is on top of net-2.6.  Please merge it for 2.6.36.
Thanks!

The following changes since commit 053d8f6622701f849fda2ca2c9ae596c13599ba9:

  Merge branch 'vhost-net' of git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost (2010-09-09 21:59:51 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git vhost-net

Michael S. Tsirkin (1):
      vhost-net: fix range checking in mrg bufs case

 drivers/vhost/net.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)
