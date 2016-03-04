From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 0/5] Misc minor documentation fixes
Date: Fri,  4 Mar 2016 12:52:36 +0100
Message-ID: <1457092361-17603-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:48607 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752211AbcCDLxZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Mar 2016 06:53:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following five patches contain minor changes to documentation at
various places. They are all unrelated, but being lazy as I am, I
submit them in one go.

Phil Sutter (5):
  tc: pedit: document branch control in help output
  man: ip-link: Beef up VXLAN csum options a bit
  man: tc-u32: Minor syntax fix
  man: ip-route: Make synopsis consistent with description
  doc, man: ip-rule: Remove incorrect statement about rule 0

 doc/ip-cref.tex        | 3 ---
 man/man8/ip-link.8.in  | 6 +++---
 man/man8/ip-route.8.in | 2 +-
 man/man8/ip-rule.8     | 2 --
 man/man8/tc-u32.8      | 1 +
 tc/m_pedit.c           | 3 ++-
 6 files changed, 7 insertions(+), 10 deletions(-)

-- 
2.7.2
