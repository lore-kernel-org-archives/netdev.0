From: Mirko Lindner <mlindner@marvell.com>
Subject: [PATCH 0/2] sky2: Bug fixes
Date: Tue, 26 Mar 2013 17:38:28 +0100
Message-ID: <6676087.yBMeFJ6grC@mlindner-lin>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog119.obsmtp.com ([74.125.149.246]:59199 "EHLO
	na3sys009aog119.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933789Ab3CZQml (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 12:42:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please find here 2 bug fixes related to the sky2 driver

These are both patches against net-next but should be
applied to -stable as well.

Mirko Lindner (2):
  Receive Overflows not counted
  Threshold for Pause Packet is set wrong

 drivers/net/ethernet/marvell/sky2.c |    2 +-
 drivers/net/ethernet/marvell/sky2.h |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

-- 
1.7.10.4
