From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH net-next-2.6 00/13] net-caif: introducing CAIF protocol
 stack
Date: Fri, 22 Jan 2010 10:43:17 +0100
Message-ID: <1264153397.3469.33.camel@violet>
References: <1264028130-14364-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	stefano.babic@babic.homelinux.org, randy.dunlap@oracle.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:45508 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753246Ab0AVJmR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2010 04:42:17 -0500
In-Reply-To: <1264028130-14364-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sjur,

> This patch-set introduces the CAIF protocol Stack.
> 
> The "Communication CPU to Application CPU Interface" (CAIF) is a packet based
> connection-oriented MUX protocol developed by ST-Ericsson for use with its
> modems.
> 
> * CAIF provides a socket interface which can be used to open virtual AT
>   channels, create and configure GPRS Data connections.
> 
> * A CAIF Network device is also provided for GPRS access.
>   This interface can be managed with socket IOCTLs or RTNL.
> 
> * A kernel interface is provided allowing Kernel modules to use CAIF.
> 
> * A serial link layer layer implemented as a line discipline is currently 
>   implemented. Other link interfaces may be contributed at a later stage.

any details on potential USB, SPI or SDIO drivers?

Regards

Marcel


