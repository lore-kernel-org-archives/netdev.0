From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/2] NetXen: Fix NetXen driver ping on system-p
Date: Tue, 08 May 2007 01:15:55 -0400
Message-ID: <4640078B.4040704@garzik.org>
References: <Pine.LNX.4.64.0705040907390.21891@dut46>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev mailing list <netdev@vger.kernel.org>,
	Rob Mapes <rob@netxen.com>, netxenproj@linsyssoft.com
To: Mithlesh Thukral <mithlesh@netxen.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54288 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967888AbXEHFP5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2007 01:15:57 -0400
In-Reply-To: <Pine.LNX.4.64.0705040907390.21891@dut46>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mithlesh Thukral wrote:
> NetXen: Fix for driver on System-p
> This patch will fix a ping issue on system-p.
> 
> Signed-off by: Milan Bag <mbag@netxen.com>
> Signed-off by: Adhiraj Joshi <adhiraj@netxen.com>
> Signed-by: Mithlesh Thukral <mithlesh@netxen.com>
> 
> ---
> 
>  drivers/net/netxen/netxen_nic_init.c |    2 +-
>  1 files changed, 1 insertion(+), 1 deletion(-)

ACK but doesn't apply


