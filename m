From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 0/3] Minor ipv6 mcast cleanups
Date: Tue, 20 Aug 2013 12:21:59 +0200
Message-ID: <1376994122-3022-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47870 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750858Ab3HTKWH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Aug 2013 06:22:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Borkmann (3):
  net: ipv6: igmp6_event_query: use msecs_to_jiffies
  net: ipv6: minor: *_start_timer: rather use unsigned long
  net: ipv6: mcast: minor: use defines for rfc3810/8.1 lengths

 net/ipv6/mcast.c | 30 ++++++++++++++++--------------
 1 file changed, 16 insertions(+), 14 deletions(-)

-- 
1.7.11.7
