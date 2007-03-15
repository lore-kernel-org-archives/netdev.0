From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/2] NetXen: Bug fix for Jumbo frames on XG card
Date: Thu, 15 Mar 2007 11:00:07 -0400
Message-ID: <45F95F77.9070903@garzik.org>
References: <200703131213.l2DCDDhN008925@dut39.unminc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amitkale@netxen.com,
	netxenproj@linsyssoft.com, rob@netxen.com
To: Linsys Contractor Mithlesh Thukral <mithlesh@netxen.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:50143 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030359AbXCOPAK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Mar 2007 11:00:10 -0400
In-Reply-To: <200703131213.l2DCDDhN008925@dut39.unminc.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linsys Contractor Mithlesh Thukral wrote:
> NetXen: Set the MTU for the right port depending upon the port number
> for XG cards.
> 
> Signed-off by: Mithlesh Thukral <mithlesh@netxen.com>
> ---
> 
>  drivers/net/netxen/netxen_nic_hw.c |    5 ++++-
>  1 files changed, 4 insertions(+), 1 deletion(-)

applied 1-2 to #upstream-fixes


