From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tg3: add amd8131 to "write reorder" chipsets
Date: Fri, 07 Jul 2006 12:12:20 -0700 (PDT)
Message-ID: <20060707.121220.99179918.davem@davemloft.net>
References: <20060707185831.GC22636@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:9873
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932272AbWGGTLs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jul 2006 15:11:48 -0400
To: linville@tuxdriver.com
In-Reply-To: <20060707185831.GC22636@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Fri, 7 Jul 2006 14:58:36 -0400

> Add the AMD 8131 bridge to the list of chipsets that reorder writes.
> 
> Signed-off-by: John W. Linville <linville@tuxdriver.com>

What failure report is this chipset blacklist addition based
upon?  I just want to look at the paper trail before adding
this.

Thanks.
