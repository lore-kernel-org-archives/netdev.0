From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.21] NetXen: Fix hardware access for ppc architecture.
Date: Thu, 29 Mar 2007 08:27:16 -0400
Message-ID: <460BB0A4.1070601@garzik.org>
References: <200703231521.l2NFLOu4023764@dut39.unminc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amitkale@netxen.com,
	netxenproj@linsyssoft.com, rob@netxen.com
To: Linsys Contractor Adhiraj Joshi <adhiraj@netxen.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52554 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753399AbXC2M1S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Mar 2007 08:27:18 -0400
In-Reply-To: <200703231521.l2NFLOu4023764@dut39.unminc.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linsys Contractor Adhiraj Joshi wrote:
> NetXen: Fix for hardware access on big endian machine. 
> 
> Signed-off-by: Adhiraj Joshi <adhiraj@netxen.com>
> 
> ---
> 
>  netxen_nic_init.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletion(-)

applied


