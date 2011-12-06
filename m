From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next 0/3] bridge forwarding database patches
Date: Tue, 06 Dec 2011 15:02:23 -0800
Message-ID: <20111206230223.191544130@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sfca-50.vyatta.com ([76.74.103.50]:49453 "EHLO fiji.vyatta.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753416Ab1LFXFr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Dec 2011 18:05:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These three patches address issue of receiving packets when
bridge mac address is modified.
