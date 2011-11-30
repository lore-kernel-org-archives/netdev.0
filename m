From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH for-3.2] tools/virtio: add module.h stub
Date: Wed, 30 Nov 2011 16:46:48 +0200
Message-ID: <20111130144647.GA24789@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

make it build with linux 3.2

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 tools/virtio/linux/module.h |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)
 create mode 100644 tools/virtio/linux/module.h

diff --git a/tools/virtio/linux/module.h b/tools/virtio/linux/module.h
new file mode 100644
index 0000000..96868eb
--- /dev/null
+++ b/tools/virtio/linux/module.h
@@ -0,0 +1,3 @@
+#ifndef LINUX_MODULE_H
+#define LINUX_MODULE_H
+#endif
-- 
1.7.5.53.gc233e
