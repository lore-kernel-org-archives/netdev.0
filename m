From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH] MAINTAINERS: add virtio-dev ML for virtio
Date: Sun, 12 Jan 2014 13:37:56 +0200
Message-ID: <20140112113756.GA9127@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>,
        Andrew Morton <akpm@linux-foundation.org>,
        Joe Perches <joe@perches.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Mauro Carvalho Chehab <m.chehab@samsung.com>,
        "David S. Miller" <davem@davemloft.net>, amit.shah@redhat.com,
        Jason Wang <jasowang@redhat.com>,
        Wanlong Gao <gaowanlong@cn.fujitsu.com>,
        virtio-dev@lists.oasis-open.org, netdev@vger.kernel.org,
        virtualization@lists.linux-foundation.org
To: linux-kernel@vger.kernel.org
Return-path: <virtio-dev-return-228-gcvd-virtio-dev=m.gmane.org@lists.oasis-open.org>
Sender: <virtio-dev@lists.oasis-open.org>
List-Post: <mailto:virtio-dev@lists.oasis-open.org>
List-Help: <mailto:virtio-dev-help@lists.oasis-open.org>
List-Unsubscribe: <mailto:virtio-dev-unsubscribe@lists.oasis-open.org>
List-Subscribe: <mailto:virtio-dev-subscribe@lists.oasis-open.org>
Content-Disposition: inline
List-Id: netdev.vger.kernel.org

Since virtio is an OASIS standard draft now, virtio implementation
discussions are taking place on the virtio-dev OASIS mailing list.
Update MAINTAINERS.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 MAINTAINERS              |   3 +
 drivers/net/virtio_net.c | 355 +++++++++++++++++++++++++----------------------
 2 files changed, 191 insertions(+), 167 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index ffcaf97..75202af 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -9088,6 +9088,7 @@ F:	include/media/videobuf2-*
 
 VIRTIO CONSOLE DRIVER
 M:	Amit Shah <amit.shah@redhat.com>
+L:	virtio-dev@lists.oasis-open.org
 L:	virtualization@lists.linux-foundation.org
 S:	Maintained
 F:	drivers/char/virtio_console.c
@@ -9097,6 +9098,7 @@ F:	include/uapi/linux/virtio_console.h
 VIRTIO CORE, NET AND BLOCK DRIVERS
 M:	Rusty Russell <rusty@rustcorp.com.au>
 M:	"Michael S. Tsirkin" <mst@redhat.com>
+L:	virtio-dev@lists.oasis-open.org
 L:	virtualization@lists.linux-foundation.org
 S:	Maintained
 F:	drivers/virtio/
@@ -9109,6 +9111,7 @@ F:	include/uapi/linux/virtio_*.h
 VIRTIO HOST (VHOST)
 M:	"Michael S. Tsirkin" <mst@redhat.com>
 L:	kvm@vger.kernel.org
+L:	virtio-dev@lists.oasis-open.org
 L:	virtualization@lists.linux-foundation.org
 L:	netdev@vger.kernel.org
 S:	Maintained
-- 
MST
