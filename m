From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] phy layer: add kernel-doc + DocBook
Date: Fri, 09 Feb 2007 16:34:52 -0500
Message-ID: <45CCE8FC.7000304@garzik.org>
References: <20070207213026.3ae3c732.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, afleming@FREESCALE.COM,
	akpm <akpm@osdl.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60514 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752531AbXBIVe4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Feb 2007 16:34:56 -0500
In-Reply-To: <20070207213026.3ae3c732.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Randy Dunlap wrote:
> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> Convert function documentation in drivers/net/phy/ to kernel-doc
> and add it to DocBook.
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
> ---
>  Documentation/DocBook/kernel-api.tmpl |    6 +
>  drivers/net/phy/mdio_bus.c            |   19 ++-
>  drivers/net/phy/phy.c                 |  192 ++++++++++++++++++++++++----------
>  drivers/net/phy/phy_device.c          |  114 +++++++++++++-------
>  4 files changed, 234 insertions(+), 97 deletions(-)

ACK but patch does not support to linux-2.6.git


