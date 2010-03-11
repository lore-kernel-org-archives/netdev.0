From: Jan Engelhardt <jengelh@medozas.de>
Subject: iproute2: IFLA_STATS64
Date: Thu, 11 Mar 2010 21:00:33 +0100
Message-ID: <1268337635-7031-1-git-send-email-jengelh@medozas.de>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: stephen.hemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:33741 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753805Ab0CKUAj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Mar 2010 15:00:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Just a small compose filler here to mark it as iproute2 stuff.

---
 include/linux/if_link.h |   33 +++++++++++++++++++++++
 ip/ipaddress.c          |   55 ++++++++++++++++++++++++++++++++++++++-
 2 files changed, 87 insertions(+), 1 deletions(-)
