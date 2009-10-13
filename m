From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: allow sh_eth to get mac address through platform
 data
Date: Tue, 13 Oct 2009 03:46:14 -0700 (PDT)
Message-ID: <20091013.034614.226601436.davem@davemloft.net>
References: <20091009101714.31039.91896.sendpatchset@rxone.opensource.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lethal@linux-sh.org,
	linux-sh@vger.kernel.org
To: magnus.damm@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49886
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759455AbZJMKqS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 06:46:18 -0400
In-Reply-To: <20091009101714.31039.91896.sendpatchset@rxone.opensource.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Magnus Damm <magnus.damm@gmail.com>
Date: Fri, 09 Oct 2009 19:17:14 +0900

> From: Magnus Damm <damm@opensource.se>
> 
> Extend the sh_eth driver to allow passing the mac address
> using the platform data structure. This to simplify board
> setup code.
> 
> Signed-off-by: Magnus Damm <damm@opensource.se>
> Tested-by: Kuninori Morimoto <morimoto.kuninori@renesas.com>

Applied to net-next-2.6
