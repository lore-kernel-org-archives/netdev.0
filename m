From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/5] NetXen: Removal of extra free_irq call
Date: Sun, 03 Jun 2007 11:48:17 -0400
Message-ID: <4662E2C1.8080804@garzik.org>
References: <200706011113.l51BD8HW004651@dut39.unminc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amitkale@netxen.com,
	netxenproj@linsyssoft.com, rob@netxen.com
To: Mithlesh Thukral <mithlesh@netxen.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:38318 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753790AbXFCPsT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Jun 2007 11:48:19 -0400
In-Reply-To: <200706011113.l51BD8HW004651@dut39.unminc.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mithlesh Thukral wrote:
> NetXen: Removal of redundant free_irq
> This patch removes a redundant free_irq() call from remove() routine.
> This will also eliminate a warning during unload of driver.
> 
> Signed-by: Mithlesh Thukral <mithlesh@netxen.com>
> ---
> 
>  drivers/net/netxen/netxen_nic_main.c |    2 --
>  1 files changed, 2 deletions(-)

applied to #upstream-fixes


