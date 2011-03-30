From: Roopa Prabhu <roprabhu@cisco.com>
Subject: [net-next-2.6 PATCH 0/4] enic: updates to version 2.1.1.13
Date: Tue, 29 Mar 2011 23:35:46 -0700
Message-ID: <20110330063533.7187.80458.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-3.cisco.com ([171.71.176.72]:29589 "EHLO
	sj-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754175Ab1C3Gfq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2011 02:35:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series implements the following enic driver updates:

01/4 - enic: Add support for new fw devcmds for port profile handling
02/4 - enic: Add wrapper routines for new fw devcmds for port profile handling
03/4 - enic: Cleanups in port profile helper code
04/4 - enic: Add support for PORT_REQUEST_PREASSOCIATE_RR

Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>
Signed-off-by: Christian Benvenuti <benve@cisco.com>
