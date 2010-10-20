From: Vasanthy Kolluri <vkolluri@cisco.com>
Subject: [net-next-2.6 PATCH 0/5] enic: updates to version 1.4.1.6
Date: Wed, 20 Oct 2010 13:16:53 -0700
Message-ID: <20101020201609.26870.80308.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roprabhu@cisco.com, dwang2@cisco.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:26189 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754994Ab0JTUQy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Oct 2010 16:16:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following patch series implements enic driver updates:

1/5 - Add support for multiple hardware receive queues
2/5 - Make firmware cognizant of the user set mac address
3/5 - Replace firmware devcmd CMD_ENABLE with CMD_ENABLE_WAIT
4/5 - Change min MTU
5/5 - Fix log message

Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>
