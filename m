From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 0/3] Advertise tunnel parameters via netlink
Date: Fri,  9 Nov 2012 17:09:58 +0100
Message-ID: <1352477401-19044-1-git-send-email-nicolas.dichtel@6wind.com>
References: <1352467239.19779.564.camel@edumazet-glaptop>
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:57916 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754264Ab2KIP6M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2012 10:58:12 -0500
In-Reply-To: <1352467239.19779.564.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The goal of this serie is to advertise tunnel parameters via netlink.

It is usefull for daemons that monitor link event to have the full parameters
of these interfaces.

The patch against iproute2 will be sent once the patches are included and
net-next merged. I can send it on demand.

v2: remove last patch of the serie, which was a bug fix.
    enhance commit log.

Comments are welcome.

Regards,
Nicolas
