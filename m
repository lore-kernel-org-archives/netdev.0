From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [GIT PULL net-2.6] vhost-net: logging fixup
Date: Sun, 12 Dec 2010 12:09:43 +0200
Message-ID: <20101212100943.GA12725@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, virtualization@lists.osdl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	stable@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please merge the following fix for 2.6.37.
It is also applicable to -stable.
Thanks!

The following changes since commit a19faf0250e09b16cac169354126404bc8aa342b:

  net: fix skb_defer_rx_timestamp() (2010-12-10 16:20:56 -0800)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git vhost-net

Michael S. Tsirkin (1):
      vhost: correctly set bits of dirty pages

 drivers/vhost/vhost.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)
