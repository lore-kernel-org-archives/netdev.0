From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PULL] vhost-net: 2.6.38 fix
Date: Fri, 14 Jan 2011 11:33:02 +0200
Message-ID: <20110114093302.GA702@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, virtualization@lists.osdl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please pull the following for 2.6.38.
Thanks!

The following changes since commit 0c21e3aaf6ae85bee804a325aa29c325209180fd:

  Merge branch 'for-next' of git://git.kernel.org/pub/scm/linux/kernel/git/hch/hfsplus (2011-01-07 17:16:27 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git vhost-net

Michael S. Tsirkin (1):
      vhost: fix signed/unsigned comparison

 drivers/vhost/vhost.c |   18 +++++++++++-------
 1 files changed, 11 insertions(+), 7 deletions(-)
