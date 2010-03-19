From: Vasanthy Kolluri <vkolluri@cisco.com>
Subject: [net-next PATCH 0/5] enic: updates to version 1.3.1.1
Date: Thu, 18 Mar 2010 19:19:38 -0700
Message-ID: <20100319021901.10527.9869.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:42758 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751080Ab0CSCTj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Mar 2010 22:19:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series implements enic driver updates:

1/5 - Bug Fix: Fix hardware descriptor reads
2/5 - Bug Fix: Fix timeout for hardware Tx and Rx queue disable operations
3/5 - Do not advertise NETIF_F_HW_VLAN_RX
4/5 - Clean up: Add wrapper functions
5/5 - Clean up: Change driver description; Fix tab space; Update MAINTAINERS

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
