From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net-next] nfp: remove Rolf Neugebauer as co-maintainer
Date: Fri,  4 Mar 2016 15:58:07 +0900
Message-ID: <1457074687-18610-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
	Simon Horman <simon.horman@netronome.com>
To: David Miller <davem@davemloft.net>,
	Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:35899 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751149AbcCDG6e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 01:58:34 -0500
Received: by mail-pa0-f49.google.com with SMTP id fi3so27831016pac.3
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2016 22:58:33 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rolf is no longer in his previous role at Netronome and as far as I know no
longer working on the NFP driver. Thus it does not seem appropriate for him
to be a co-maintainer anymore.

Reviewed-by: Dinan Gunawardena <dinan.gunawardena@netronome.com>
Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 MAINTAINERS | 1 -
 1 file changed, 1 deletion(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index f5d772686ddf..be0b56b38720 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -7501,7 +7501,6 @@ F:	net/netrom/
 
 NETRONOME ETHERNET DRIVERS
 M:	Jakub Kicinski <jakub.kicinski@netronome.com>
-M:	Rolf Neugebauer <rolf.neugebauer@netronome.com>
 L:	oss-drivers@netronome.com
 S:	Maintained
 F:	drivers/net/ethernet/netronome/
-- 
2.7.0.rc3.207.g0ac5344
