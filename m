From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 0/4 2.6.29] cxgb3 - driver updates
Date: Wed, 26 Nov 2008 12:36:57 -0800
Message-ID: <492DB369.3020505@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	Steve Wise <swise@opengridcomputing.com>
To: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:11184 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752746AbYKZUhM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2008 15:37:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[cc-ing Dave in Jeff's absence]

Hi Jeff,

I'm submitting 4 update patches against net-next-2.6 for inclusion in 
2.6.29.
Here is a brief description of the patch series:
- add missing ndo_start_xmit setting
- fix parameter checking in memory allocation routine
- include firmware and protocol engine images in the firmware/ directory
- update firmware and protocol engine images lookup path

Cheers,
Divy
