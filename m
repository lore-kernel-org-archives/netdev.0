From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 3/5] NetXen: Add NETXEN prefix to macros
Date: Sun, 03 Jun 2007 11:50:29 -0400
Message-ID: <4662E345.3070908@garzik.org>
References: <200706011115.l51BFahX004752@dut39.unminc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amitkale@netxen.com,
	netxenproj@linsyssoft.com, rob@netxen.com
To: Mithlesh Thukral <mithlesh@netxen.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:38375 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752505AbXFCPub (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Jun 2007 11:50:31 -0400
In-Reply-To: <200706011115.l51BFahX004752@dut39.unminc.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mithlesh Thukral wrote:
> NetXen: Add NETXEN prefix to a macro
> This patch will add the "NETXEN" prefix to "USER_START" macro.
> 
> Signed-off by: Wen Xiong <wenxiong@us.ibm.com>
> Signed-off by: Mithlesh Thukral <mithlesh@netxen.com>
> ---
> 
>  drivers/net/netxen/netxen_nic.h         |    4 ++--
>  drivers/net/netxen/netxen_nic_ethtool.c |    2 +-
>  drivers/net/netxen/netxen_nic_hw.c      |    4 ++--
>  drivers/net/netxen/netxen_nic_init.c    |    4 ++--
>  4 files changed, 7 insertions(+), 7 deletions(-)

Your patch description is useless.  Clearly we know -what- it does, 
simply by reading the patch.

But it does not answer the simple question:  why?  why is this needed in 
a bug fix Release Candidate series?


