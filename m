From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 4/8][ATM]: [he] remove linux/version.h include
Date: Tue, 19 Jul 2005 16:45:31 -0400
Message-ID: <200507192045.j6JKjUpV027205@ginger.cmf.nrl.navy.mil>
Cc: davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6 -- thanks!

[ATM]: [he] remove linux/version.h include

  Signed-off-by: Olaf Hering <olh@suse.de>
  Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>


---
commit 9c893a8cd5716416ee719a57e04e01aeb2c68bd3
tree ae99b267a7f35cec41df7ccdfb9aa3695a3e2b67
parent eefc05048924978c1e28835bf5085c5de2e653d2
author chas williams <chas@relax.(none)> Tue, 19 Jul 2005 15:06:23 -0400
committer chas williams <chas@relax.(none)> Tue, 19 Jul 2005 15:06:23 -0400

 drivers/atm/he.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/atm/he.c b/drivers/atm/he.c
--- a/drivers/atm/he.c
+++ b/drivers/atm/he.c
@@ -57,7 +57,6 @@
 
 #include <linux/config.h>
 #include <linux/module.h>
-#include <linux/version.h>
 #include <linux/kernel.h>
 #include <linux/skbuff.h>
 #include <linux/pci.h>
