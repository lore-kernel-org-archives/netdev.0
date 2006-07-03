From: brice@myri.com
Subject: [patch 0/4] myri10ge minor updates
Date: Mon, 03 Jul 2006 18:02:30 -0400
Message-ID: <20060703220230.606593000@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:44215 "EHLO
	myri.com") by vger.kernel.org with ESMTP id S932146AbWGCWII (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jul 2006 18:08:08 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

the following patches bring some minor updates for the myri10ge driver:
1) Drop unused pm_state
2) Drop ununsed nvidia chipset id
3) Use dev_info() when printing parameters after probe
4) Export more parameters to ethtool

Please apply.

thanks,
Brice

