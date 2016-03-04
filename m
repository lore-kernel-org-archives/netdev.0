From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 0/2] ip-neighbour: Add missing nud state descriptions
Date: Fri,  4 Mar 2016 20:07:19 +0100
Message-ID: <1457118441-15349-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:54154 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758710AbcCDTHe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Mar 2016 14:07:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following aims at documenting all nud states 'ip neigh' supports, not just
the most common ones. This includes describing them in the relevant man page as
well as extending 'ip neigh help' output.

Phil Sutter (2):
  man: ip-neighbour.8: Document all known nud states
  ipneigh: List all nud states in help output

 ip/ipneigh.c            |  9 +++++----
 man/man8/ip-neighbour.8 | 22 +++++++++++++++++++++-
 2 files changed, 26 insertions(+), 5 deletions(-)

-- 
2.7.2
