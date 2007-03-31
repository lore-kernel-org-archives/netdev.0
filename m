From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 2.6.21 0/4] cxgb3 - bug fixes
Date: Fri, 30 Mar 2007 23:12:50 -0800
Message-ID: <460E09F2.80201@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Steve Wise <swise@opengridcomputing.com>
To: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:27835 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750848AbXCaHNE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Mar 2007 03:13:04 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jeff,

I'm submitting a set of bug fixes for inclusion in 2.6.21.
The patches are built against Linus'git tree.

Here is a brief description:
- Ensure that the on-board TCAM's active region size is always greater 
than 16
- the driver now recognizes NIC only adapters
- tighten the MAC hang workaround
- bump up firmware version

Cheers,
Divy
