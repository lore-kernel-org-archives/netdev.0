From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vxge: use pci_dma_mapping_error to test return value
Date: Sun, 10 Jan 2010 13:40:33 -0800 (PST)
Message-ID: <20100110.134033.198454104.davem@davemloft.net>
References: <20100105211659.GA12882@coldcone>
	<20100108.005528.263100819.davem@davemloft.net>
	<20100109195222.GA4271@coldcone>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "kirjanov@gmail.com"@sunset.davemloft.net.davemloft.net,
	kirjanov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53033
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753834Ab0AJVkZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2010 16:40:25 -0500
In-Reply-To: <20100109195222.GA4271@coldcone>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis Kirjanov <kirjanov@gmail.com" <kirjanov@gmail.com>
Date: Sat, 9 Jan 2010 22:52:22 +0300

> My mistake. Fixed one.
> 
> pci_dma_mapping_error should be used to test return value of
> pci_map_single or pci_map_page.
> 
> Signed-off-by: Denis Kirjanov <kirjanov@gmail.com>

Applied, thanks.
