From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2 v2] KS8695: fix ks8695_rx_irq() bug.
Date: Mon, 16 Nov 2009 23:51:50 -0800 (PST)
Message-ID: <20091116.235150.100049181.davem@davemloft.net>
References: <efc9214f0911160718o4c7cd0ecv2e86b8d5ad7691ae@mail.gmail.com>
	<1258045910.1931.16.camel@myhost>
	<efc9214f0911162028te62eca0h90f11b9b1e7a5d6e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: figo1802@gmail.com, netdev@vger.kernel.org, ben@simtec.co.uk
To: zealcook@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43250
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754053AbZKQHvd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 02:51:33 -0500
In-Reply-To: <efc9214f0911162028te62eca0h90f11b9b1e7a5d6e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: zeal <zealcook@gmail.com>
Date: Tue, 17 Nov 2009 12:28:33 +0800

> 'the corresponding status bit has been clear(irq's ack)' is not enough?

I think it is sufficient, patch applied, thanks!
