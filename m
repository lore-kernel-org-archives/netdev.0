From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] MAINTAINERS: release Scott from being a rocker maintainer
Date: Sun, 10 Jul 2016 09:42:44 +0200
Message-ID: <1468136564-2245-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, sfeldma@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34904 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932198AbcGJHms (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jul 2016 03:42:48 -0400
Received: by mail-wm0-f66.google.com with SMTP id k123so12802320wme.2
        for <netdev@vger.kernel.org>; Sun, 10 Jul 2016 00:42:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

As requested by Scott, removing him.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 MAINTAINERS | 1 -
 1 file changed, 1 deletion(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 6374be2..06e8411 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -9710,7 +9710,6 @@ F:	Documentation/ABI/*/sysfs-driver-hid-roccat*
 
 ROCKER DRIVER
 M:	Jiri Pirko <jiri@resnulli.us>
-M:	Scott Feldman <sfeldma@gmail.com>
 L:	netdev@vger.kernel.org
 S:	Supported
 F:	drivers/net/ethernet/rocker/
-- 
2.5.5
