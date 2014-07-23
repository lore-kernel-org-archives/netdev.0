From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 1/5] net: bcmgenet: remove FSF mail address
Date: Wed, 23 Jul 2014 10:42:11 -0700
Message-ID: <1406137335-1671-2-git-send-email-f.fainelli@gmail.com>
References: <1406137335-1671-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:39204 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932674AbaGWRni (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2014 13:43:38 -0400
Received: by mail-pa0-f52.google.com with SMTP id bj1so2162017pad.39
        for <netdev@vger.kernel.org>; Wed, 23 Jul 2014 10:43:38 -0700 (PDT)
In-Reply-To: <1406137335-1671-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use a smaller GPLv2 header and remove all the boilerplate code as well
as the FSF mail address.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c |  9 ---------
 drivers/net/ethernet/broadcom/genet/bcmgenet.h | 14 ++------------
 drivers/net/ethernet/broadcom/genet/bcmmii.c   |  9 ---------
 3 files changed, 2 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 0173a6d355aa..0c7af0b2f164 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -6,15 +6,6 @@
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful,
- * but WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
- * GNU General Public License for more details.
- *
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
  */
 
 #define pr_fmt(fmt)				"bcmgenet: " fmt
diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.h b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
index c61cd98b662e..2ef8673943de 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.h
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
@@ -4,18 +4,8 @@
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful,
- * but WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
- * GNU General Public License for more details.
- *
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
- *
- *
-*/
+ */
+
 #ifndef __BCMGENET_H__
 #define __BCMGENET_H__
 
diff --git a/drivers/net/ethernet/broadcom/genet/bcmmii.c b/drivers/net/ethernet/broadcom/genet/bcmmii.c
index b1338c9e8abb..fb801d53c443 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmmii.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmmii.c
@@ -6,15 +6,6 @@
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful,
- * but WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
- * GNU General Public License for more details.
- *
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
  */
 
 
-- 
1.9.1
