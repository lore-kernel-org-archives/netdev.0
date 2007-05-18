From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/2] NetXen: Fix NetXen driver ping on system-p
Date: Thu, 17 May 2007 20:46:10 -0400
Message-ID: <464CF752.5070403@garzik.org>
References: <200705171352.l4HDqPL9023075@dut39.unminc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amitkale@netxen.com,
	netxenproj@linsyssoft.com, rob@netxen.com
To: Mithlesh Thukral <mithlesh@netxen.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:43566 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756812AbXERAqM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 May 2007 20:46:12 -0400
In-Reply-To: <200705171352.l4HDqPL9023075@dut39.unminc.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mithlesh Thukral wrote:
> NetXen: Fix for driver on System-p
> This patch will fix a ping issue on system-p
> 
> Signed-off by: Milan Bag <mbag@netxen.com>
> Signed-off by: Adhiraj Joshi <adhiraj@netxen.com>
> Signed-by: Mithlesh Thukral <mithlesh@netxen.com>
> ---
>  drivers/net/netxen/netxen_nic_init.c |    2 +-
>  1 files changed, 1 insertion(+), 1 deletion(-)

applied


