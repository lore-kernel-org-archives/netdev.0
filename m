From: Casey Leedom <leedom@chelsio.com>
Subject: [PATCH net-next-26 0/5] cxgb4vf: minor cleanup
Date: Thu, 11 Nov 2010 11:30:39 -0800
Message-ID: <1289503844-18059-1-git-send-email-leedom@chelsio.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:21089 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754644Ab0KKTau (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 14:30:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes to comments, compiler warnings, etc.

 drivers/net/cxgb4vf/adapter.h      |    2 +-
 drivers/net/cxgb4vf/cxgb4vf_main.c |   32 ++++++++++++++++++++------------
 drivers/net/cxgb4vf/sge.c          |    9 ++++++---
 drivers/net/cxgb4vf/t4vf_common.h  |   28 ++++++++++++++--------------
 drivers/net/cxgb4vf/t4vf_hw.c      |    5 +++--
 5 files changed, 44 insertions(+), 32 deletions(-)

