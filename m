From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 0/5] bridge: RCU annotation and cleanup
Date: Sun, 14 Nov 2010 13:12:01 -0800
Message-ID: <20101114211201.678755903@vyatta.com>
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:52958 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755071Ab0KNVSJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 Nov 2010 16:18:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a split up of what Eric did with a couple of small changes and additions.

