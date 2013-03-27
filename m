From: Tony Cheneau <tony.cheneau@amnesiak.org>
Subject: [PATCH net-next 0/2] 6lowpan: fix minor issues introduced with the previous patch set
Date: Wed, 27 Mar 2013 00:09:23 -0400
Message-ID: <1364357365-21080-1-git-send-email-tony.cheneau@amnesiak.org>
Cc: Alan Ott <alan@signal11.us>,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	netdev@vger.kernel.org, linux-zigbee-devel@lists.sourceforge.net
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.amnesiak.org ([95.130.11.136]:35315 "EHLO amnesiak.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751067Ab3C0EKj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Mar 2013 00:10:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Few minor issues were reported by Alexander Aring and Sergei Shtylyov on my
previous 6lowpan patch set (named "6lowpan: Some more bug fixes").
Sadly, I didn't had time to address them before the code was merged into
net-next. These two (short) patches fix them.

I'm sorry for the mess I caused.

Regards,
    Tony Cheneau

Tony Cheneau (2):
  6lowpan: fix a small formatting issue
  6lowpan: use IEEE802154_ADDR_LEN instead of a magic number

 net/ieee802154/6lowpan.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

-- 
1.7.12.4
