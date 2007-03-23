From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] mv643xx_eth: add mv643xx_eth_shutdown function
Date: Fri, 23 Mar 2007 01:50:26 -0400
Message-ID: <46036AA2.2050001@pobox.com>
References: <20070320233801.GA24374@xyzzy.farnsworth.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60464 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753196AbXCWFu2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Mar 2007 01:50:28 -0400
In-Reply-To: <20070320233801.GA24374@xyzzy.farnsworth.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dale Farnsworth wrote:
> From: Dale Farnsworth <dale@farnsworth.org>
> 
> mv643xx_eth_shutdown is needed for kexec.
> 
> Signed-off-by: Dale Farnsworth <dale@farnsworth.org>
> 
> ---
>  drivers/net/mv643xx_eth.c |   14 ++++++++++++++
>  1 file changed, 14 insertions(+)

applied


