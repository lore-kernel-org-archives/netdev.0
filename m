From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 0/6] vxlan: port related patches
Date: Sat, 27 Apr 2013 14:31:51 -0700
Message-ID: <20130427213151.255971631@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fiji.vyatta.com ([76.74.103.50]:52174 "EHLO fiji.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754122Ab3D0Vqg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Apr 2013 17:46:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Looking at VxLan issues around destination port found some cleanups,
a bug, and an enhancement to allow configuring per device.
