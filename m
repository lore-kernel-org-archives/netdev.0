From: Johannes Berg <johannes@sipsolutions.net>
Subject: cfg80211 take 7
Date: Fri, 06 Oct 2006 16:59:50 +0200
Message-ID: <1160146790.2715.82.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:16034 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S932432AbWJFO7D
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Oct 2006 10:59:03 -0400
To: netdev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hah, take 6 was eaten by netdev (even the announcement) but it did reach
some people (and before those who did get it wonder: I resent to netdev,
the original mail was accidentally not addressed to netdev, so it's not
that I simply didn't send it).

anyway, it's getting large, so... straight from quilt:
http://johannes.sipsolutions.net/files/cfg80211/

order is:
nl80211.patch
move-wext.patch
wext-compat.patch

johannes
