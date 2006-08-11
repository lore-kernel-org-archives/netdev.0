From: David Miller <davem@davemloft.net>
Subject: Re: [DECNET] Fix to decnet rules compare function
Date: Fri, 11 Aug 2006 16:44:49 -0700 (PDT)
Message-ID: <20060811.164449.13027314.davem@davemloft.net>
References: <20060811155406.GA560@souterrain.chygwyn.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, patrick@tykepenguin.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:64728
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751254AbWHKXog (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Aug 2006 19:44:36 -0400
To: steve@chygwyn.com
In-Reply-To: <20060811155406.GA560@souterrain.chygwyn.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Steven Whitehouse <steve@chygwyn.com>
Date: Fri, 11 Aug 2006 16:54:06 +0100

> Here is a fix to the DECnet rules compare function where we used
> 32bit values rather than 16bit values. Spotted by Patrick McHardy.
> 
> Cc: Patrick McHardy <kaber@trash.net>
> Cc: Patrick Caulfield <patrick@tykepenguin.com>
> Signed-off-by: Steven Whitehouse <steve@chygwyn.com>

Applied, thanks a lot.
