From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 2.6.21 0/3] cxgb3 - bug fixes
Date: Tue, 17 Apr 2007 11:06:05 -0700
Message-ID: <46250C8D.1010809@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Steve Wise <swise@opengridcomputing.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:14081 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161280AbXDQSGN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2007 14:06:13 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jeff,

I'm submitting a set of bug fixes for inclusion in 2.6.21.
The patches are built against Linus'git tree.

Here is a brief description:
- Fix resource usage in low memory conditions,
- PHY interrupts can use any GPIO pin.

Cheers,
Divy
