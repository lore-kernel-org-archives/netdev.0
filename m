From: Casey Leedom <leedom@chelsio.com>
Subject: [PATCH net-26 0/6] cxgb4vf: a number of bug fixes
Date: Thu, 11 Nov 2010 11:06:47 -0800
Message-ID: <1289502413-9895-1-git-send-email-leedom@chelsio.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:12387 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753259Ab0KKTG7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 14:06:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following patch set includes a number of bug fixes for the cxgb4vf
network driver.  As always, please toss these in the bin if they're not
right.

 drivers/net/cxgb4vf/cxgb4vf_main.c |   42 ++++++++-----
 drivers/net/cxgb4vf/sge.c          |  122 ++++++++++++++++++++++--------------
 drivers/net/cxgb4vf/t4vf_common.h  |    1 +
 drivers/net/cxgb4vf/t4vf_hw.c      |   19 ++++++
 4 files changed, 122 insertions(+), 62 deletions(-)

