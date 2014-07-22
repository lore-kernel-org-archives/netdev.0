From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH ethtool 0/1] ethtool: add support for rx_copybreak
Date: Tue, 22 Jul 2014 23:03:59 +0530
Message-ID: <1406050440-13447-1-git-send-email-_govind@gmx.com>
Cc: davem@davemloft.net, ssujith@cisco.com, benve@cisco.com,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: ben@decadent.org.uk, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.201]:57265 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756348AbaGVRed (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jul 2014 13:34:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for displaying and setting driver's rx_copybreak.

Please apply this to ethtool when the kernel changes are accepted.

Thanks

Govindarajulu Varadarajan (1):
  ethtool: add support for rxcopybreak

 ethtool-copy.h |  2 ++
 ethtool.c      | 18 +++++++++++++-----
 2 files changed, 15 insertions(+), 5 deletions(-)

-- 
2.0.2
