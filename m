From: David Miller <davem@davemloft.net>
Subject: Re: [VLAN]: Fix memset length
Date: Sat, 14 Jul 2007 18:56:45 -0700 (PDT)
Message-ID: <20070714.185645.126763028.davem@davemloft.net>
References: <46967007.1050200@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, greearb@candelatech.com
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33296
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932385AbXGOB4n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jul 2007 21:56:43 -0400
In-Reply-To: <46967007.1050200@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 12 Jul 2007 20:16:39 +0200

> [VLAN]: Fix memset length
> 
> Fix sizeof(ETH_ALEN) Introduced by my rtnl_link patches.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied, thanks.
