From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 0/2] lnstat: review --subject option
Date: Wed, 18 Nov 2015 16:57:45 +0100
Message-ID: <1447862267-13603-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:54694 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755191AbbKRP6A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Nov 2015 10:58:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add missing description in help output, fix algorithm.

Phil Sutter (2):
  lnstat: describe -s option in help output
  lnstat: fix header displaying mechanism

 misc/lnstat.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

-- 
2.5.0
