From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 0/1] Update my email address in MODULE_AUTHOR
Date: Sat, 17 Mar 2012 09:39:28 +0100
Message-ID: <cover.1331973209.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:48972 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752002Ab2CQIjf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Mar 2012 04:39:35 -0400
Received: by wejx9 with SMTP id x9so4560686wej.19
        for <netdev@vger.kernel.org>; Sat, 17 Mar 2012 01:39:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I keep on getting email messages saying, "I tried to email you at the
other address, but it bounces."

This patch correct my email address in four PTP related modules.

Richard Cochran (1):
  phc: Update author's email address.

 drivers/net/ethernet/freescale/gianfar_ptp.c |    2 +-
 drivers/net/phy/dp83640.c                    |    2 +-
 drivers/ptp/ptp_clock.c                      |    2 +-
 drivers/ptp/ptp_ixp46x.c                     |    2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

-- 
1.7.2.5
