From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] myri10ge: check fragmentation in LRO
 get_frag_header()
Date: Tue, 09 Dec 2008 00:14:36 -0800 (PST)
Message-ID: <20081209.001436.251704319.davem@davemloft.net>
References: <493CE630.3010809@myri.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: brice@myri.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47712
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752042AbYLIIOf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2008 03:14:35 -0500
In-Reply-To: <493CE630.3010809@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brice Goglin <brice@myri.com>
Date: Mon, 08 Dec 2008 10:17:36 +0100

> Add a fragmentation check to myri10ge's LRO get_frag_header() callback.
> 
> Signed-off-by: Brice Goglin <brice@myri.com>
> Signed-off-by: Andrew Gallatin <gallatin@myri.com> 

Applied, thanks Brice.
