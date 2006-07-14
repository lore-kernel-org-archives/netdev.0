From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.18-rc1-mm2: drivers/char/*synclink* compile errors
Date: Fri, 14 Jul 2006 14:31:40 -0700 (PDT)
Message-ID: <20060714.143140.35508183.davem@davemloft.net>
References: <20060713224800.6cbdbf5d.akpm@osdl.org>
	<20060714184825.GB3633@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, khc@pm.waw.pl, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:62878
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1161303AbWGNVbd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jul 2006 17:31:33 -0400
To: bunk@stusta.de
In-Reply-To: <20060714184825.GB3633@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>
Date: Fri, 14 Jul 2006 20:48:25 +0200

> Krzysztof, the following compile errors are caused by your commit 
> c2ce920468624d87ec5f91f080ea99681dae6d88 in Linus' tree:

Yes, we let Krzysztof know about this yesterday.

If we don't get a fix over the weekend I will simply
revert the changeset.

Thanks Adrian.
