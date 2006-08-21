From: Brice Goglin <brice@myri.com>
Subject: [PATCH 0/2] myri10ge: updates for 2.6.19
Date: Mon, 21 Aug 2006 17:36:32 -0400
Message-ID: <44EA2760.9020504@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:9959 "EHLO
	myri.com") by vger.kernel.org with ESMTP id S1751201AbWHUVhL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2006 17:37:11 -0400
To: Jeff Garzik <jeff@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff,

Here's 2 patches for myri10ge for 2.6.19.

1) use netif_msg_link
As you requested after I sent my first patch to make link status change
reporting configurable, I reworked the code to use netif_msg_link. I
sent this new version last week without getting any complains, so I hope
it is ok to get merged now.

2) use multicast support in the firmware

Please apply.

Thank you,
Brice Goglin

