From: David Miller <davem@davemloft.net>
Subject: Re: crash in ipt_do_table
Date: Thu, 17 Aug 2006 18:14:03 -0700 (PDT)
Message-ID: <20060817.181403.78708132.davem@davemloft.net>
References: <20060815005422.0c47bddb.akpm@osdl.org>
	<44E1D3A2.3020604@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chris@ex-parrot.com, akpm@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:57035
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932246AbWHRBNy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Aug 2006 21:13:54 -0400
To: kaber@trash.net
In-Reply-To: <44E1D3A2.3020604@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Tue, 15 Aug 2006 16:01:06 +0200

> Any chance you're also changing your ruleset dynamically? If yes
> this patch might help.

I've applied this.
