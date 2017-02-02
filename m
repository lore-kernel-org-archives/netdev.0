From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] MAINTAINERS: add Ivan as a switchdev maintainer
Date: Thu,  2 Feb 2017 17:05:04 +0100
Message-ID: <1486051504-19623-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, ivecera@redhat.com, idosch@mellanox.com,
        mlxsw@mellanox.com, jhs@mojatatu.com, roopa@cumulusnetworks.com,
        f.fainelli@gmail.com, vivien.didelot@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34410 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751734AbdBBQFH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 11:05:07 -0500
Received: by mail-wm0-f66.google.com with SMTP id c85so4968541wmi.1
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 08:05:06 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Ivan will be taking care of switchdev code from now on.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 MAINTAINERS | 1 +
 1 file changed, 1 insertion(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 300d2ec..eacacb2 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -11908,6 +11908,7 @@ F:	include/linux/swiotlb.h
 
 SWITCHDEV
 M:	Jiri Pirko <jiri@resnulli.us>
+M:	Ivan Vecera <ivecera@redhat.com>
 L:	netdev@vger.kernel.org
 S:	Supported
 F:	net/switchdev/
-- 
2.7.4
