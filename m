From: David Miller <davem@davemloft.net>
Subject: Re: [DECnet] Convert rwlock to spinlock
Date: Wed, 09 Aug 2006 16:01:14 -0700 (PDT)
Message-ID: <20060809.160114.35662514.davem@davemloft.net>
References: <20060809100633.GB23935@souterrain.chygwyn.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, patrick@tykepenguin.com,
	shemminger@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:59032
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751424AbWHIXBk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 19:01:40 -0400
To: steve@chygwyn.com
In-Reply-To: <20060809100633.GB23935@souterrain.chygwyn.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Steven Whitehouse <steve@chygwyn.com>
Date: Wed, 9 Aug 2006 11:06:33 +0100

> As per Stephen Hemminger's recent patch to ipv4/fib_semantics.c this
> is the same change but for DECnet.
> 
> Signed-off-by: Steven Whitehouse <steve@chygwyn.com>

Also applied, thanks Steven.
