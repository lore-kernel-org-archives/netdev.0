From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [GIT PULL] last minute vhost-net fix
Date: Thu, 13 May 2010 11:44:34 +0300
Message-ID: <20100513084433.GA23082@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, virtualization@lists.osdl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David, if it's not too late, please pull the following
last minute fix into 2.6.34.
Thanks!

The following changes since commit de02d72bb3cc5b3d4c873db4ca8291723dd48479:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6 (2010-05-10 22:53:41 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git net-2.6

Michael S. Tsirkin (1):
      vhost: fix barrier pairing

 drivers/vhost/vhost.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

-- 
MST
