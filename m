From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] NIU: Implement discard counters
Date: Thu, 18 Dec 2008 19:48:38 -0800 (PST)
Message-ID: <20081218.194838.122455220.davem@davemloft.net>
References: <1229608331.16904.23.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, netdev@vger.kernel.org
To: hawk@comx.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33245
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752374AbYLSDsg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2008 22:48:36 -0500
In-Reply-To: <1229608331.16904.23.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <hawk@comx.dk>
Date: Thu, 18 Dec 2008 14:52:11 +0100

> 
> This patch series implements discard counter stats for the NIU driver.
> 
> This work has been done together with Robert Olsson.  We have come to a
> stage where the patches needs public review, and possible discussion.
> 
> Tested with hardware:
>  Sun Quad GbE x8 PCIe
>  Sun Dual 10GbE XFP PCIe

To be honest these patches look great, I'll add them to
net-next-2.6

Thanks!
