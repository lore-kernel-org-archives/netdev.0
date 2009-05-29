From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH 2/10]: wavelan: Remove bogus debugging on skb->next
	being non-NULL.
Date: Fri, 29 May 2009 12:17:56 +0200
Message-ID: <20090529101754.GA3506@tuxdriver.com>
References: <20090529.014002.66716606.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:55711 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756204AbZE2Kad (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 06:30:33 -0400
Content-Disposition: inline
In-Reply-To: <20090529.014002.66716606.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 29, 2009 at 01:40:02AM -0700, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Fcc: +backup
> X-Mailer: Mew version 6.2.51 on Emacs 22.1 / Mule 5.0 (SAKAKI)
> ----
> 
> This eliminates explicit references to the SKB list handling
> implementation.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>

ACK

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
