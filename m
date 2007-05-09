From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] atl1: add netconsole support
Date: Wed, 09 May 2007 19:25:24 -0400
Message-ID: <46425864.7070802@garzik.org>
References: <20070509145235.GA5712@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jacliburn@bellsouth.net
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:50066 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755807AbXEIXZ1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 May 2007 19:25:27 -0400
In-Reply-To: <20070509145235.GA5712@martell.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Dobriyan wrote:
> Copied from b44 driver, but it works:
> 
> netconsole: device eth0 not up yet, forcing it
> atl1: eth0 link is up 100 Mbps full duplex
> netconsole: network logging started
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> ---
> 
>  drivers/net/atl1/atl1_main.c |   12 ++++++++++++
>  1 file changed, 12 insertions(+)

applied


