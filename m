From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH 1/6] SMSC LAN911x and LAN921x vendor driver
Date: Thu, 06 Nov 2008 12:48:21 +0000
Message-ID: <1225975701.16885.7.camel@pc1117.cambridge.arm.com>
References: <1225881342-3485-1-git-send-email-steve.glendinning@smsc.com>
	 <1225881342-3485-2-git-send-email-steve.glendinning@smsc.com>
	 <491287E8.70704@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Steve Glendinning <steve.glendinning@smsc.com>,
	netdev@vger.kernel.org, Bahadir.Balban@arm.com,
	dustin@sensoria.com, bgat@billgatliff.com,
	Ian Saturley <ian.saturley@smsc.com>, g.liakhovetski@gmx.de,
	Peter Korsgaard <jacmet@sunsite.dk>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cam-admin0.cambridge.arm.com ([193.131.176.58]:53777 "EHLO
	cam-admin0.cambridge.arm.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753605AbYKFMst (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2008 07:48:49 -0500
In-Reply-To: <491287E8.70704@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-11-06 at 01:00 -0500, Jeff Garzik wrote:
> Steve Glendinning wrote:
> > Attached is a driver for SMSC's LAN911x and LAN921x families of embedded
> > ethernet controllers.
[...]
> applied patch #1

Could you please apply patch #2 as well? The subsequent patches probably
won't compile without the dynamic bus configuration as they make use of
it.

Thanks.

-- 
Catalin

