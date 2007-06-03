From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 5/5] NetXen: Fix link status messages
Date: Sun, 03 Jun 2007 11:51:44 -0400
Message-ID: <4662E390.6050904@garzik.org>
References: <200706011117.l51BHGYG004794@dut39.unminc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amitkale@netxen.com,
	netxenproj@linsyssoft.com, rob@netxen.com
To: Mithlesh Thukral <mithlesh@netxen.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:38401 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752476AbXFCPvq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Jun 2007 11:51:46 -0400
In-Reply-To: <200706011117.l51BHGYG004794@dut39.unminc.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mithlesh Thukral wrote:
> NetXen: Correct link status messages.
> This patch will fix the problem of wrong link status messages
> that were reported. 
> 
> Signed-off by: Wen Xiong <wenxiong@us.ibm.com>
> Signed-off by: Mithlesh Thukral <mithlesh@netxen.com>
> ---
> 
>  drivers/net/netxen/netxen_nic.h      |    1 +
>  drivers/net/netxen/netxen_nic_init.c |   21 +++++++++++++--------
>  drivers/net/netxen/netxen_nic_isr.c  |   23 +++++++++++++++++++++++
>  3 files changed, 37 insertions(+), 8 deletions(-)

dropped due to previous patches being dropped


