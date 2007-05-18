From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/2] NetXen: Updates for register access routines
Date: Thu, 17 May 2007 20:47:28 -0400
Message-ID: <464CF7A0.2090604@garzik.org>
References: <200705171353.l4HDr9eb023094@dut39.unminc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amitkale@netxen.com,
	netxenproj@linsyssoft.com, rob@netxen.com
To: Mithlesh Thukral <mithlesh@netxen.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:43610 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757357AbXERAra (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 May 2007 20:47:30 -0400
In-Reply-To: <200705171353.l4HDr9eb023094@dut39.unminc.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mithlesh Thukral wrote:
> NetXen: Changes related to registers and their access routines
> This patch updates the various access routines to access different
> control and status settings present in different register locations.
> This will fix problems related to working of different ports in
> multi Port card.
> 
> Signed-off by: Milan Bag <mbag@netxen.com>
> Signed-off by: Adhiraj Joshi <adhiraj@netxen.com>
> Acked-by: Mithlesh Thukral <mithlesh@netxen.com>
> ---
>  drivers/net/netxen/netxen_nic.h      |   96 ++++++++++---------------
>  drivers/net/netxen/netxen_nic_hw.h   |   65 +++-------------
>  drivers/net/netxen/netxen_nic_init.c |   17 ++--
>  3 files changed, 65 insertions(+), 113 deletions(-)

not applied.  This patch removes a bunch of endianness changes.


