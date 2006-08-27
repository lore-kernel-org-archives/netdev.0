From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] bridge-netfilter fixes
Date: Sat, 26 Aug 2006 20:27:54 -0700 (PDT)
Message-ID: <20060826.202754.115910695.davem@davemloft.net>
References: <20060823001050.363374000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:5785
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750872AbWH0D2D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Aug 2006 23:28:03 -0400
To: shemminger@osdl.org
In-Reply-To: <20060823001050.363374000@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: shemminger@osdl.org
Date: Tue, 22 Aug 2006 17:10:50 -0700

> This set of patches fixes issues with bridge netfilter code.
> First patch is for 2.6.18 and fixes a crash. Later patches
> could be deferred, they just cleanup the style, usage, etc.

What a nasty bug.

I'll push the bug fix to Linus for 2.6.18 right now, and
after he eats that I'll rebase net-2.6.19 then put your
other 3 patches on top.

Thanks.
