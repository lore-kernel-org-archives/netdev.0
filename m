From: Shreeya Patel <shreeya.patel23498@gmail.com>
Subject: [PATCH] Staging: irda: Remove trailing whitespace errors
Date: Sat, 14 Oct 2017 02:05:35 +0530
Message-ID: <1507926935-3552-1-git-send-email-shreeya.patel23498@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Shreeya Patel <shreeya.patel23498@gmail.com>
To: gregkh@linuxfoundation.org, samuel@sortiz.org, netdev@vger.kernel.org,
 devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org,
 outreachy-kernel@googlegroups.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

Remove trailing whitespace checkpatch errors.

Signed-off-by: Shreeya Patel <shreeya.patel23498@gmail.com>
---
 drivers/staging/irda/drivers/esi-sir.c | 22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/staging/irda/drivers/esi-sir.c b/drivers/staging/irda/drivers/esi-sir.c
index 019a3e8..eb7aa64 100644
--- a/drivers/staging/irda/drivers/esi-sir.c
+++ b/drivers/staging/irda/drivers/esi-sir.c
@@ -1,5 +1,5 @@
 /*********************************************************************
- *                
+ *
  * Filename:      esi.c
  * Version:       1.6
  * Description:   Driver for the Extended Systems JetEye PC dongle
@@ -8,25 +8,25 @@
  * Created at:    Sat Feb 21 18:54:38 1998
  * Modified at:   Sun Oct 27 22:01:04 2002
  * Modified by:   Martin Diehl <mad@mdiehl.de>
- * 
+ *
  *     Copyright (c) 1999 Dag Brattli, <dagb@cs.uit.no>,
  *     Copyright (c) 1998 Thomas Davis, <ratbert@radiks.net>,
  *     Copyright (c) 2002 Martin Diehl, <mad@mdiehl.de>,
  *     All Rights Reserved.
- *     
- *     This program is free software; you can redistribute it and/or 
- *     modify it under the terms of the GNU General Public License as 
- *     published by the Free Software Foundation; either version 2 of 
+ *
+ *     This program is free software; you can redistribute it and/or
+ *     modify it under the terms of the GNU General Public License as
+ *     published by the Free Software Foundation; either version 2 of
  *     the License, or (at your option) any later version.
- * 
+ *
  *     This program is distributed in the hope that it will be useful,
  *     but WITHOUT ANY WARRANTY; without even the implied warranty of
  *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
  *     GNU General Public License for more details.
- * 
- *     You should have received a copy of the GNU General Public License 
+ *
+ *     You should have received a copy of the GNU General Public License
  *     along with this program; if not, see <http://www.gnu.org/licenses/>.
- *     
+ *
  ********************************************************************/
 
 #include <linux/module.h>
@@ -97,7 +97,7 @@ static int esi_change_speed(struct sir_dev *dev, unsigned speed)
 {
 	int ret = 0;
 	int dtr, rts;
-	
+
 	switch (speed) {
 	case 19200:
 		dtr = TRUE;
-- 
2.7.4
