From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next] MAINTAINERS: add netdev list for PTP (IEEE 1588)
Date: Tue, 26 Mar 2013 15:01:12 +0100
Message-ID: <4b0d96e199e0c4ff5efa90c14ea457067321125c.1364306426.git.jbenc@redhat.com>
Cc: Richard Cochran <richardcochran@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5224 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758268Ab3CZOBw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Mar 2013 10:01:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 MAINTAINERS |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 86c0843..77b3748 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -6310,6 +6310,7 @@ F:	drivers/acpi/apei/erst.c
 
 PTP HARDWARE CLOCK SUPPORT
 M:	Richard Cochran <richardcochran@gmail.com>
+L:	netdev@vger.kernel.org
 S:	Maintained
 W:	http://linuxptp.sourceforge.net/
 F:	Documentation/ABI/testing/sysfs-ptp
-- 
1.7.6.5
