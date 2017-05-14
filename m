From: Maciek Fijalkowski <macfij7@wp.pl>
Subject: [PATCH 3/3] Fix ERROR: code indent should use tabs where possible
Date: Sun, 14 May 2017 19:51:30 +0200
Message-ID: <20170514175130.18664-3-macfij7@wp.pl>
References: <20170514175130.18664-1-macfij7@wp.pl>
Cc: jasonwang@redhat.com, virtualization@lists.linux-foundation.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Maciej Fijalkowski <macfij7@wp.pl>
To: mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170514175130.18664-1-macfij7@wp.pl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Maciej Fijalkowski <macfij7@wp.pl>

Signed-off-by: Maciej Fijalkowski <macfij7@wp.pl>
---
 drivers/net/virtio_net.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 6c8170c..5d71e9f 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -2717,7 +2717,7 @@ static __init int virtio_net_driver_init(void)
 	if (ret)
 		goto err_dead;
 
-        ret = register_virtio_driver(&virtio_net_driver);
+	ret = register_virtio_driver(&virtio_net_driver);
 	if (ret)
 		goto err_virtio;
 	return 0;
-- 
2.4.11
