From: <netanel@amazon.com>
Subject: [PATCH net-next] MAINTAINERS: change ENA driver maintainers email domain
Date: Tue, 17 Oct 2017 07:30:34 +0000
Message-ID: <1508225434-105787-1-git-send-email-netanel@amazon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Netanel Belgazal <netanel@amazon.com>, <dwmw@amazon.com>,
        <zorik@amazon.com>, <matua@amazon.com>, <saeedb@amazon.com>,
        <msw@amazon.com>, <aliguori@amazon.com>, <nafea@amazon.com>,
        <evgenys@amazon.com>
To: <linux-kernel@vger.kernel.org>, <davem@davemloft.net>,
        <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Netanel Belgazal <netanel@amazon.com>

ENA driver was developed by developers from Annapurna Labs.
Annapurna Labs was acquired by Amazon and the company's domain
(@annapurnalabs.com) will become deprecated soon.

Update the email addresses of the maintainers to the alternative amazon
emails (@amazon.com)

Signed-off-by: Netanel Belgazal <netanel@amazon.com>
---
 MAINTAINERS | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 3944f1626911..f218fe1e43fe 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -700,9 +700,9 @@ F:	include/linux/altera_uart.h
 F:	include/linux/altera_jtaguart.h
 
 AMAZON ETHERNET DRIVERS
-M:	Netanel Belgazal <netanel@annapurnalabs.com>
-R:	Saeed Bishara <saeed@annapurnalabs.com>
-R:	Zorik Machulsky <zorik@annapurnalabs.com>
+M:	Netanel Belgazal <netanel@amazon.com>
+R:	Saeed Bishara <saeedb@amazon.com>
+R:	Zorik Machulsky <zorik@amazon.com>
 L:	netdev@vger.kernel.org
 S:	Supported
 F:	Documentation/networking/ena.txt
-- 
1.8.3.1
