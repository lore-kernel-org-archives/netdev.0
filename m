From: Roopa Prabhu <roprabhu@cisco.com>
Subject: [net-next-2.6 PATCH 0/7] enic: updates to version 1.4.1.2
Date: Tue, 10 Aug 2010 21:54:50 -0700
Message-ID: <20100811045436.3877.51650.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:10491 "EHLO
	sj-iport-4.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751441Ab0HKEyv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Aug 2010 00:54:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series implements the following enic driver updates:

01/7 - Add set mac address
02/7 - Add support for firmware management device
03/7 - Add new firmware devcmds
04/7 - Use offsetof macro in vic tlv length calculation
05/7 - Clean up: remove enic_dev_stats_clear
06/7 - Check if rq/wq buf not NULL before freeing them
07/7 - Mark intr_timer in vnic_enet_config as deprecated


Signed-off-by: Scott Feldman <scofeldm@cisco.com>
Signed-off-by: Roopa Prabhu<roprabhu@cisco.com>
Signed-off-by: Vasanthy Kolluri<vkolluri@cisco.com>
