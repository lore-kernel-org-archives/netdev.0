From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 0/3 2.6.27] cxgb3 - driver updates
Date: Tue, 20 May 2008 18:57:17 -0700
Message-ID: <4833817D.2060305@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Jeff Garzik <jeff@garzik.org>, NetDev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Steve Wise <swise@opengridcomputing.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:9210 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756169AbYEUB5V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2008 21:57:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jeff,

I'm submitting 3 update patches against netdev-2.6#upstream for 
inclusion in 2.6.27.
Here is a brief description of the patch series:
- Check pci mapping errors
- Feed the Jumbo frame Rx queue with pages
- Add support for LRO

Cheers,
Divy
