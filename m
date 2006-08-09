From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCHSET]: Clean up netlink NLM_F_ECHO and rtnl event notifications
Date: Wed, 09 Aug 2006 22:48:21 +0200
Message-ID: <20060809204821.216122988@postel.suug.ch>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:18338 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1751342AbWHIUzF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 16:55:05 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Aims at cleaning up rtnetlink event notifications and implements
real NLM_F_ECHO support.

Please disregard my last IPv4 routing related patchset, I'll
resubmit it based on this patchset.

