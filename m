From: Vasanthy Kolluri <vkolluri@cisco.com>
Subject: [net-next-2.6 PATCH 0/3] enic: updates to version 2.1.1.9
Date: Thu, 17 Feb 2011 10:53:06 -0800
Message-ID: <20110217185245.2476.60944.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:40358 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757648Ab1BQSxH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Feb 2011 13:53:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series implements enic driver updates:

1/3 - Bug fix: Reset driver count of registered unicast addresses to zero during device reset
2/3 - Clean up: Remove a not needed #ifdef
3/3 - Always use single transmit and single receive hardware queues per device

Signed-off-by: Christian Benvenuti <benve@cisco.com>
Signed-off-by: Danny Guo <dannguo@cisco.com>
Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>
