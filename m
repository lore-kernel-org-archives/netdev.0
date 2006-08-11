From: David Miller <davem@davemloft.net>
Subject: Re: [NET 01/06]: Use u32 for routing table IDs
Date: Thu, 10 Aug 2006 23:08:43 -0700 (PDT)
Message-ID: <20060810.230843.116964587.davem@davemloft.net>
References: <20060810192957.14867.71965.sendpatchset@localhost.localdomain>
	<20060810192959.14867.66066.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, patrick@tykepenguin.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:33989
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751554AbWHKGIf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Aug 2006 02:08:35 -0400
To: kaber@trash.net
In-Reply-To: <20060810192959.14867.66066.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 10 Aug 2006 21:29:59 +0200 (MEST)

> [NET]: Use u32 for routing table IDs
> 
> Use u32 for routing table IDs in net/ipv4 and net/decnet in preparation of
> support for a larger number of routing tables. net/ipv6 already uses u32
> everywhere and needs no further changes. No functional changes are made by
> this patch.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied.
