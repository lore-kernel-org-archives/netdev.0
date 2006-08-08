From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipx: header length validation needed
Date: Mon, 07 Aug 2006 20:10:47 -0700 (PDT)
Message-ID: <20060807.201047.51418736.davem@davemloft.net>
References: <20060807134636.30f8b779@localhost.localdomain>
	<20060807.162433.26101101.davem@davemloft.net>
	<20060807163602.5c7a4a65@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@ghostprotocols.net, netdev@vger.kernel.org, stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:49639
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751230AbWHHDKo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 23:10:44 -0400
To: shemminger@osdl.org
In-Reply-To: <20060807163602.5c7a4a65@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Mon, 7 Aug 2006 16:36:02 -0700

> This patch will linearize and check there is enough data.
> It handles the pprop case as well as avoiding a whole audit of
> the routing code.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Applied, with a minor coding style tidy-up.

Thanks a lot Stephen.
