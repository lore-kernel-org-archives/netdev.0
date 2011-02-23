From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next 0/6] netem patches
Date: Wed, 23 Feb 2011 15:04:16 -0800
Message-ID: <20110223230416.532009518@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:47468 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754667Ab1BWXHt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Feb 2011 18:07:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These have been resting in a moldy place for far to long.
The most important is the integration of a better packet
loss model for netem

