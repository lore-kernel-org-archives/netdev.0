From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 0/9] cxgb3 - driver update
Date: Fri, 16 Nov 2007 11:19:55 -0800
Message-ID: <473DED5B.5070802@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Steve Wise <swise@opengridcomputing.com>,
	Wen Xiong <wenxiong@us.ibm.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:20404 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752082AbXKPTVg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2007 14:21:36 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff, Dave,

I'm submitting a patch series for inclusion in 2.6.25.
The patches are built against netdev#upstream.

Here is a brief description:
- Fix error path when requesting MSI-X resources
- Use wild card for PCI Vendor ID
- Fix sysfs resource release
- Add PCI error recovery support
- FW upgrade
- Fix interaction with pktgen
- Remove unused argument in sysfs related methods
- HW setup update
- Synchronize I/O access on Tx path

Cheers,
Divy


