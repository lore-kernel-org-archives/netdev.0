From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 18/18] Bluetooth: Declare MODULE_FIRMWARE for Marvell SDIO driver
Date: Thu,  3 Dec 2009 19:45:55 +0100
Message-ID: <2861453b1b5e022fd5e1294b8fbf39254440b661.1259865280.git.marcel@holtmann.org>
References: <cover.1259865279.git.marcel@holtmann.org>
 <b3cf652afb5404685e3d7ed6780a8d1fa10e21da.1259865280.git.marcel@holtmann.org>
 <5990108cfcd3eb2d365c9ea6f82318be80c4e9d3.1259865280.git.marcel@holtmann.org>
 <329ab1b3e6ceac3f77ab400206a97cc402624259.1259865280.git.marcel@holtmann.org>
 <fed4c2508b7419d0a55958fead6151b32def1683.1259865280.git.marcel@holtmann.org>
 <2da31939a42f7a676a0bc5155d6a0a39ed8451f2.1259865280.git.marcel@holtmann.org>
 <7e21addcd0ad87696c17409399e56e874931da57.1259865280.git.marcel@holtmann.org>
 <76bca88012e1d27de794f32cc551d6314d38b6d9.1259865280.git.marcel@holtmann.org>
 <c78ae283145d3a8799b2fb01650166a66af3bff8.1259865280.git.marcel@holtmann.org>
 <cde9f807f003676862178a6f28b52c7d431511ed.1259865280.git.marcel@holtmann.org>
 <0565c1c24af94130b891f989fa608faddfadc52c.1259865280.git.marcel@holtmann.org>
 <889a3ca466018ab68363c3168993793bc2d984f1.1259865280.git.marcel@holtmann.org>
 <9f121a5a80b4417c6db5a35e26d2e79c29c3fc0d.1259865280.git.marcel@holtmann.org>
 <4ec10d9720ef78cd81d8bcc30a3238665744569f.1259865280.git.marcel@holtmann.org>
 <2ab25cdd7b54473dd42dcffc9872737de2517466.1259865280.git.marcel@holtmann.org>
 <32fd63981ed453bd882f22e3e9b0ccbc11fb47e5.1259865280.git.marcel@holtmann.org>
 <5fbcd3d1a07e234583e17830e8aef47282c22141.1259865280.git.marcel@holtmann.org>
 <eae38eede2e5f70d65f09327297bd698b0d3ea7e.1259865280.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:37656 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756531AbZLCSqE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 13:46:04 -0500
In-Reply-To: <eae38eede2e5f70d65f09327297bd698b0d3ea7e.1259865280.git.marcel@holtmann.org>
In-Reply-To: <cover.1259865279.git.marcel@holtmann.org>
References: <cover.1259865279.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 drivers/bluetooth/btmrvl_sdio.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/bluetooth/btmrvl_sdio.c b/drivers/bluetooth/btmrvl_sdio.c
index d6aaf51..1e6eb1a 100644
--- a/drivers/bluetooth/btmrvl_sdio.c
+++ b/drivers/bluetooth/btmrvl_sdio.c
@@ -1003,3 +1003,5 @@ MODULE_AUTHOR("Marvell International Ltd.");
 MODULE_DESCRIPTION("Marvell BT-over-SDIO driver ver " VERSION);
 MODULE_VERSION(VERSION);
 MODULE_LICENSE("GPL v2");
+MODULE_FIRMWARE("sd8688_helper.bin");
+MODULE_FIRMWARE("sd8688.bin");
-- 
1.6.5.2

