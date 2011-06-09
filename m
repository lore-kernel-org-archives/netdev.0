From: Vasanthy Kolluri <vkolluri@cisco.com>
Subject: [net-next-2.6 PATCH 0/4] enic: updates to version 2.1.1.20
Date: Thu, 09 Jun 2011 13:36:46 -0700
Message-ID: <20110609203620.31838.61879.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-3.cisco.com ([171.71.176.72]:38903 "EHLO
	sj-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750774Ab1FIUgu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2011 16:36:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series implements enic driver updates:

1/4 - Pass 802.1p bits for packets tagged with vlan zero
2/4 - Change log message during driver load
3/4 - Get/Set interrupt resource index for transmit and receive queues
4/4 - Bug Fix: Fix hardware transmit queue indexing in enic_poll_controller

Signed-off-by: Christian Benvenuti <benve@cisco.com>
Signed-off-by: Danny Guo <dannguo@cisco.com>
Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>
