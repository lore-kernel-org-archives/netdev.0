From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3,GIT 0/5] support for DSA hardware ethernet switch
 chips
Date: Wed, 08 Oct 2008 17:29:47 -0700 (PDT)
Message-ID: <20081008.172947.250946906.davem@davemloft.net>
References: <20081007234342.GA23200@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: buytenh@wantstofly.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53936
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754724AbYJIAaL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 20:30:11 -0400
In-Reply-To: <20081007234342.GA23200@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lennert Buytenhek <buytenh@wantstofly.org>
Date: Wed, 8 Oct 2008 01:43:42 +0200

> This is version 3 of the DSA patch set, with various improvements
> over v2:
 ...
> Lennert Buytenhek (5):
>       [NET] Distributed Switch Architecture protocol support
>       [NET] dsa: add support for original DSA tagging format
>       [NET] dsa: add support for the Marvell 88E6131 switch chip
>       [NET] dsa: add support for Trailer tagging format
>       [NET] dsa: add support for the Marvell 88E6060 switch chip

All applied and pushed out to net-next-2.6, thanks!
