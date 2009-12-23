From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH NEXT 1/4] netxen: minor suspend resume fixes
Date: Wed, 23 Dec 2009 14:15:15 -0800 (PST)
Message-ID: <20091223.141515.226761280.davem@davemloft.net>
References: <1260340857-11487-1-git-send-email-amit.salecha@qlogic.com>
	<1260340857-11487-2-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dhananjay.phadke@qlogic.com
To: amit.salecha@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42899
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757429AbZLWWPN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 17:15:13 -0500
In-Reply-To: <1260340857-11487-2-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Date: Tue,  8 Dec 2009 22:40:54 -0800

> o pci device should be disable at the end and it should be enable first.
> o Interface should be attached(netif_device_attach()) irrespective
>   of its state.
> 
> Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>

Applied.
