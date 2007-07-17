From: Johannes Berg <johannes@sipsolutions.net>
Subject: [patch 0/3] dynamic generic netlink multicast
Date: Tue, 17 Jul 2007 14:27:06 +0200
Message-ID: <20070717122706.899784000@sipsolutions.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Zhang Rui <rui.zhang@intel.com>, jamal <hadi@cyberus.ca>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:42474 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752594AbXGQMmE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2007 08:42:04 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series adds dynamic generic netlink multicast groups.
The ACPI people are open to rebasing their patches on top of this.
Both Jamal and Patrick gave it a quick review (Patrick said he'll
review it again when he gets around) and we've discussed the API
for a while ending up with this. Please apply.

johannes

