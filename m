From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.24 1/1]S2io: Support for add/delete/store/restore
 ethernet addresses
Date: Wed, 14 Nov 2007 01:43:24 -0800 (PST)
Message-ID: <20071114.014324.78802691.davem@davemloft.net>
References: <Pine.GSO.4.10.10711140429100.18735-100000@guinness>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, support@neterion.com
To: Sreenivasa.Honnur@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40177
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753701AbXKNJnZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 04:43:25 -0500
In-Reply-To: <Pine.GSO.4.10.10711140429100.18735-100000@guinness>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Date: Wed, 14 Nov 2007 04:30:34 -0500 (EST)

> - Support to add/delete/store/restore 64 and 128 Ethernet addresses for Xframe I and Xframe II respectively.
> 
> - (Resubmit third time)
> 
> Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>

No, this is a feature patch, so I'm not going to queue this
up for 2.6.24, that is not appropriate at all.

Instead I've added this patch to netdev-2.6 which will
schedule it for the 2.6.25 merge window.

I had to remove the DRV_VERSION part of your changes as
a result.

Thanks.
