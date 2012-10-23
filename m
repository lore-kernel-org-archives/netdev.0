From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/8] maintainers: update with official intel support link, new maintainer
Date: Tue, 23 Oct 2012 03:24:41 -0700
Message-ID: <1350987887-16161-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1350987887-16161-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:54686 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752560Ab2JWKYw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2012 06:24:52 -0400
In-Reply-To: <1350987887-16161-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Add an official link which is designed to guide the user to the appropriate
support resource (be it community, OEM, Intel phone, Intel email, etc)

Add the current e1000 maintainer to the list of Intel maintainers.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 41c5349..5655bcc 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3869,7 +3869,9 @@ M:	Greg Rose <gregory.v.rose@intel.com>
 M:	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
 M:	Alex Duyck <alexander.h.duyck@intel.com>
 M:	John Ronciak <john.ronciak@intel.com>
+M:	Tushar Dave <tushar.n.dave@intel.com>
 L:	e1000-devel@lists.sourceforge.net
+W:	http://www.intel.com/support/feedback.htm
 W:	http://e1000.sourceforge.net/
 T:	git git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net.git
 T:	git git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next.git
-- 
1.7.11.7
