From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] myri10ge: update firmware headers to 1.4.37
Date: Thu, 25 Dec 2008 18:09:22 -0800 (PST)
Message-ID: <20081225.180922.30075775.davem@davemloft.net>
References: <494EB4C0.4090707@myri.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: brice@myri.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35056
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752487AbYLZCJU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Dec 2008 21:09:20 -0500
In-Reply-To: <494EB4C0.4090707@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brice Goglin <brice@myri.com>
Date: Sun, 21 Dec 2008 22:27:28 +0100

> Update myri10ge firmware headers to 1.4.37:
> * Make each member of the error/cmd enum an initialized one, so there
>   is a convenient numerical reference to look for reverse conversion.
> * Add new MXGEFW_CMD_RELAX_RXBUFFER_ALIGNMENT command.
> * Add new "features" field to mcp_header.
> 
> Signed-off-by: Brice Goglin <brice@myri.com>

Applied.
