From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [GIT PULL net-next-2.6] vhost-net cleanups
Date: Thu, 27 May 2010 13:58:49 +0300
Message-ID: <20100527105849.GA7590@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, virtualization@lists.osdl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jdike@linux.intel.com, tklauser@distanz.ch
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David,
The following tree is on top of net-next-2.6.
Please merge it for 2.6.36.
Thanks!

The following changes since commit 7a9b149212f3716c598afe973b6261fd58453b7a:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/usb-2.6 (2010-05-20 21:26:12 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git vhost-net-next

Jeff Dike (1):
      vhost-net: minor cleanup

Michael S. Tsirkin (1):
      vhost: whitespace fix

Tobias Klauser (1):
      vhost: Storage class should be before const qualifier

 drivers/vhost/net.c   |   13 ++++++-------
 drivers/vhost/vhost.c |    4 ++--
 2 files changed, 8 insertions(+), 9 deletions(-)
-- 
MST
