From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 alt.3] af_packet: Don't use skb after
 dev_queue_xmit()
Date: Mon, 11 Jan 2010 15:39:58 -0800 (PST)
Message-ID: <20100111.153958.201324763.davem@davemloft.net>
References: <20100111080419.GA6061@ff.dom.local>
	<4B4BA695.7040803@majjas.com>
	<20100111224817.GB3369@del.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mbreuer@majjas.com, shemminger@vyatta.com,
	akpm@linux-foundation.org, flyboy@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50146
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751566Ab0AKXjt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2010 18:39:49 -0500
In-Reply-To: <20100111224817.GB3369@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Mon, 11 Jan 2010 23:48:17 +0100

> David, if this patch is acceptable now, please add:
> 
> With help from: David S. Miller <davem@davemloft.net>
> 
> Tested-by: Michael Breuer<mbreuer@majjas.com>

Looks great, applied, thanks everyone!
