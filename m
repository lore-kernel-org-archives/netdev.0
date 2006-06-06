From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fixup struct ip_mc_list::multiaddr type
Date: Mon, 05 Jun 2006 21:04:51 -0700 (PDT)
Message-ID: <20060605.210451.82359202.davem@davemloft.net>
References: <20060526193009.GB7266@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:45262
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750854AbWFFEEw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jun 2006 00:04:52 -0400
To: adobriyan@gmail.com
In-Reply-To: <20060526193009.GB7266@martell.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Fri, 26 May 2006 23:30:09 +0400

> All users except two expect 32-bit big-endian value. One is of
> 
> 	->multiaddr = ->multiaddr
> 
> variety. And last one is "%08lX".
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied, thanks Alexey.
