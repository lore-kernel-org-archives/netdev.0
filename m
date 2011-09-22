From: Roopa Prabhu <roprabhu@cisco.com>
Subject: [net-next-2.6 PATCH 0/3] enic: updates to version 2.1.1.28
Date: Thu, 22 Sep 2011 06:44:27 -0700
Message-ID: <20110922134410.2145.72210.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtv-iport-1.cisco.com ([173.36.130.12]:39127 "EHLO
	mtv-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751374Ab1IVNo2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2011 09:44:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series implements the following enic driver updates:

01/3 - Add SRIOV support
02/3 - Helper code for SRIOV proxy commands
03/3 - Add support for port profile association on a enic SRIOV VF

Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: Sujith Sankar <ssujith@cisco.com>
Signed-off-by: Christian Benvenuti <benve@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>
