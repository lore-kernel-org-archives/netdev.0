From: Johannes Berg <johannes@sipsolutions.net>
Subject: [patch 0/3] softmac: more fixes
Date: Thu, 20 Apr 2006 20:02:01 +0200
Message-ID: <20060420180201.092857000@sipsolutions.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:47083 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751227AbWDTSaE
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Apr 2006 14:30:04 -0400
To: "John W. Linville" <linville@tuxdriver.com>
Cc: softmac-dev@sipsolutions.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset fixes more things in softmac, the first patch implements
the SIOCSIWMLME wext, the second fixes the SIOCSIWAP wext and the third
cleans up the event code.

The second is a fairly important fix for wpa_supplicant and should probably
still go to 2.6.17, the others can go in too of course but aren't that
important I think.

johannes
