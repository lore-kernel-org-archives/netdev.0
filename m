From: kys@exchange.microsoft.com
Subject: [PATCH net-next 0/2] netvsc: Fix miscellaneous issues
Date: Fri, 24 Mar 2017 20:54:08 -0700
Message-ID: <1490414048-12578-1-git-send-email-kys@exchange.microsoft.com>
Reply-To: kys@microsoft.com
Cc: "K. Y. Srinivasan" <kys@microsoft.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, devel@linuxdriverproject.org,
        olaf@aepfle.de, apw@canonical.com, jasowang@redhat.com,
        leann.ogasawara@canonical.comi, marcelo.cerri@canonical.com,
        sthemmin@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from a2nlsmtp01-04.prod.iad2.secureserver.net ([198.71.225.38]:59990
        "EHLO a2nlsmtp01-04.prod.iad2.secureserver.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S966362AbdCYDzN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 23:55:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: K. Y. Srinivasan <kys@microsoft.com>

Fix miscellaneous issues.

K. Y. Srinivasan (2):
  netvsc: Fix a bug in sub-channel handling
  netvsc: Properly initialize the return value

 drivers/net/hyperv/netvsc_drv.c   |    2 +-
 drivers/net/hyperv/rndis_filter.c |    5 +++++
 2 files changed, 6 insertions(+), 1 deletions(-)
