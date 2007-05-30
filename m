From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 2.6.22 0/5]
Date: Wed, 30 May 2007 09:59:57 -0700
Message-ID: <465DAD8D.9030600@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Steve Wise <swise@opengridcomputing.com>
To: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:3492 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753257AbXE3RAF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2007 13:00:05 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jeff,

I'm submitting a set of bug fixes for inclusion in 2.6.22.
The patches are built against Linus'git tree.

Here is a brief description:
- Fix skb->dev dereference in,
- Fix netpoll handler,
- Fix link status detection for direct XAUI adapters,
- Work around potential hang on MTU change,
- Fix MAC watchdog.

You have already ACK'ed the link status detection fix.
I'm not sure however where it stands in your queue, so I'm resubmitting it.
Please ignore if you already processed it.

Cheers,
Divy
