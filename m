From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ppp: eliminate shadowed variable name
Date: Wed, 02 Jun 2010 05:17:23 -0700 (PDT)
Message-ID: <20100602.051723.172537674.davem@davemloft.net>
References: <20100601090546.79c1fca0@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulus@samba.org, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52596
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757604Ab0FBMRO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 08:17:14 -0400
In-Reply-To: <20100601090546.79c1fca0@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 1 Jun 2010 09:05:46 -0700

> Sparse complains about shadowed declaration of skb. So use other
> name.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
