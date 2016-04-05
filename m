From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net] MAINTAINERS: intel-wired-lan list is moderated
Date: Tue,  5 Apr 2016 16:39:37 +0200
Message-ID: <f06d4636c53b68b5368bfc817511d36a13c4dc8b.1459867159.git.jbenc@redhat.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Shannon Nelson <shannon.nelson@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34526 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751336AbcDEOj4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 10:39:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I got the following message:

> Your mail to 'Intel-wired-lan' with the subject
>
>     [PATCH net-next] net: intel: remove dead links
>
> Is being held until the list moderator can review it for approval.
>
> The reason it is being held:
>
>     Post by non-member to a members-only list

Mark the list as moderated.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 MAINTAINERS | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 7ba7bc485d74..1d8ce9b9e4f1 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5750,7 +5750,7 @@ R:	Don Skidmore <donald.c.skidmore@intel.com>
 R:	Bruce Allan <bruce.w.allan@intel.com>
 R:	John Ronciak <john.ronciak@intel.com>
 R:	Mitch Williams <mitch.a.williams@intel.com>
-L:	intel-wired-lan@lists.osuosl.org
+L:	intel-wired-lan@lists.osuosl.org (moderated for non-subscribers)
 W:	http://www.intel.com/support/feedback.htm
 W:	http://e1000.sourceforge.net/
 Q:	http://patchwork.ozlabs.org/project/intel-wired-lan/list/
-- 
1.8.3.1
