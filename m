From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH 0/2] ptp: more bug fixes for 3.1 and 3.0
Date: Tue, 20 Sep 2011 13:25:40 +0200
Message-ID: <cover.1316516989.git.richard.cochran@omicron.at>
Cc: <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These two patches fix two bugs in the PTP Hardware Clock drivers. The
drivers were first introduced in Linux version 3.0.

Thanks,
Richard

Richard Cochran (2):
  ptp: fix L2 event message recognition
  dp83640: reduce driver noise

 drivers/net/phy/dp83640.c    |    4 ++--
 include/linux/ptp_classify.h |   13 ++++++++++---
 2 files changed, 12 insertions(+), 5 deletions(-)

-- 
1.7.2.5
