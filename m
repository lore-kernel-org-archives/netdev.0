From: Gal Pressman <galp@mellanox.com>
Subject: [PATCH ethtool 0/2] Documentation fixes and additions for advertise bitmask
Date: Thu, 28 Sep 2017 15:08:51 +0300
Message-ID: <1506600533-10365-1-git-send-email-galp@mellanox.com>
Cc: Tariq Toukan <tariqt@mellanox.com>,
        Pavel Belous <pavel.s.belous@gmail.com>,
        Gal Pressman <galp@mellanox.com>
To: netdev@vger.kernel.org,
        "John W . Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:53414 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751873AbdI1MJZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 08:09:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi John,

The next two patches will fix bad formatting in the advertise modes bitmask and
document four missing 56000 modes.

Regards,
Gal.

Gal Pressman (2):
  ethtool.8: Fix formatting of advertise bitmask
  ethtool.8: Document 56000 advertise link modes

 ethtool.8.in | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

-- 
2.7.4
