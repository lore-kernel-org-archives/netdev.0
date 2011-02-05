From: Vasanthy Kolluri <vkolluri@cisco.com>
Subject: [net-next-2.6 PATCH 0/5] enic: updates to version 2.1.1.6
Date: Fri, 04 Feb 2011 18:17:00 -0800
Message-ID: <20110205021618.8510.34816.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:3249 "EHLO
	sj-iport-4.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752536Ab1BECRC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Feb 2011 21:17:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series implements enic driver updates:

1/5 - Clean up: Organize devcmd wrapper routines
2/5 - Bug Fix: Fix return values of enic_add/del_station_addr routines
3/5 - Bug Fix: Reorder firmware devcmds - CMD_INIT and CMD_IG_VLAN_REWRITE_MODE
4/5 - Clean up: Remove support for an older version of hardware
5/5 - Update MAINTAINERS

Signed-off-by: Christian Benvenuti <benve@cisco.com>
Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>
