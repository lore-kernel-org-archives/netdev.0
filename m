From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]remove deprecated and not used: print_mac()
Date: Sun, 15 Nov 2009 22:22:57 -0800 (PST)
Message-ID: <20091115.222257.196410609.davem@davemloft.net>
References: <200911131958.42263.mitov@issp.bas.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: mitov@issp.bas.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35114
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751864AbZKPGWl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 01:22:41 -0500
In-Reply-To: <200911131958.42263.mitov@issp.bas.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marin Mitov <mitov@issp.bas.bg>
Date: Fri, 13 Nov 2009 19:58:41 +0200

> The function print_mac in net/ethernet/eth.c is marked __deprecated
> and not used. Remove it.
> 
> The patch is against 2.6.32-rc7.
> 
> Signed-off-by: Marin Mitov <mitov@issp.bas.bg>

Applied, thanks.
