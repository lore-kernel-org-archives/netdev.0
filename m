From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 4/5] NetXen: Fix ping issue
Date: Sun, 03 Jun 2007 11:51:17 -0400
Message-ID: <4662E375.5020409@garzik.org>
References: <200706011116.l51BGPZf004774@dut39.unminc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amitkale@netxen.com,
	netxenproj@linsyssoft.com, rob@netxen.com
To: Mithlesh Thukral <mithlesh@netxen.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:38392 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752724AbXFCPvT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Jun 2007 11:51:19 -0400
In-Reply-To: <200706011116.l51BGPZf004774@dut39.unminc.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mithlesh Thukral wrote:
> NetXen: Fix initialization and subsequent ping issue
> This patch will fix the initialization and ping issues seen on
> certain PPC architecture blades.
> 
> Signed-off by: Wen Xiong <wenxiong@us.ibm.com>
> Signed-off by: Mithlesh Thukral <mithlesh@netxen.com>
> ---
> 
>  drivers/net/netxen/netxen_nic_main.c |    7 +++++++
>  drivers/net/netxen/netxen_nic_niu.c  |    8 ++------
>  2 files changed, 9 insertions(+), 6 deletions(-)

Again, your patch description is useless.

You should describe the problem being fixed, and how/why the changes 
seen in the patch actually fix the issue.


