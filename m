From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] filter: constify sk_run_filter()
Date: Wed, 08 Dec 2010 10:34:04 -0800 (PST)
Message-ID: <20101208.103404.48510622.davem@davemloft.net>
References: <1291704609.2769.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53865
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752614Ab0LHSdh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 13:33:37 -0500
In-Reply-To: <1291704609.2769.5.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 07 Dec 2010 07:50:09 +0100

> sk_run_filter() doesnt write on skb, change its prototype to reflect
> this.
> 
> Fix two af_packet comments.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks.
