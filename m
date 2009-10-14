From: Gregory Haskins <ghaskins@novell.com>
Subject: [NET PATCH 1/9] venet: Update maintainer
Date: Wed, 14 Oct 2009 11:58:51 -0400
Message-ID: <20091014155851.18864.89239.stgit@dev.haskins.net>
References: <20091014154457.18864.28382.stgit@dev.haskins.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: alacrityvm-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20091014154457.18864.28382.stgit@dev.haskins.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Gregory Haskins <ghaskins@novell.com>
---

 MAINTAINERS |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index fe97eb1..55fabad 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5617,6 +5617,13 @@ S:	Maintained
 F:	include/linux/vbus*
 F:	drivers/vbus/*
 
+VBUS ETHERNET DRIVER
+M:	Gregory Haskins <ghaskins@novell.com>
+S:	Maintained
+W:	http://developer.novell.com/wiki/index.php/AlacrityVM
+F:	include/linux/venet.h
+F:	drivers/net/vbus-enet.c
+
 VFAT/FAT/MSDOS FILESYSTEM
 M:	OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
 S:	Maintained

