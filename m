From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH net-next v2 0/2] 6lowpan: code updates
Date: Wed, 16 May 2012 11:27:26 +0400
Message-ID: <1337153248-5779-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:59306 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759381Ab2EPH2U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2012 03:28:20 -0400
Received: by weyu7 with SMTP id u7so241520wey.19
        for <netdev@vger.kernel.org>; Wed, 16 May 2012 00:28:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

I've resent patches with net-next tag.

Thanks,
Alex

Alexander Smirnov (2):
  6lowpan: rework data fetching from skb
  6lowpan: fix hop limit compression

 net/ieee802154/6lowpan.c |   76 ++++++++++++++++++++++++++-------------------
 1 files changed, 44 insertions(+), 32 deletions(-)

--
1.7.2.3
