From: David Miller <davem@davemloft.net>
Subject: Re: [ROSE] Try all routes when establishing a ROSE connections.
Date: Mon, 03 Jul 2006 19:32:33 -0700 (PDT)
Message-ID: <20060703.193233.115905034.davem@davemloft.net>
References: <20060630135316.GA12943@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:14268
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751371AbWGDCcS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jul 2006 22:32:18 -0400
To: ralf@linux-mips.org
In-Reply-To: <20060630135316.GA12943@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ralf Baechle <ralf@linux-mips.org>
Date: Fri, 30 Jun 2006 14:53:16 +0100

> >From Jean-Paul F6FBB:
> 
> ROSE will only try to establish a route using the first route in its
> routing table.  Fix to iterate through all additional routes if a
> connection attempt has failed.
> 
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

Applied, thanks.
