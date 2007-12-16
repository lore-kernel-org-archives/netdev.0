From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [NET]: Fix Ooops of napi net_rx_action.
Date: Sun, 16 Dec 2007 13:35:02 -0800 (PST)
Message-ID: <20071216.133502.196415640.davem@davemloft.net>
References: <36D9DB17C6DE9E40B059440DB8D95F5203F82FC3@orsmsx418.amr.corp.intel.com>
	<b25c3fa70712111527p561b3e2i24ee0fdf3d61a98c@mail.gmail.com>
	<20071211154222.0aec68fc@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joonwpark81@gmail.com, jesse.brandeburg@intel.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	herbert@gondor.apana.org.au, auke-jan.h.kok@intel.com
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48849
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754701AbXLPVfL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Dec 2007 16:35:11 -0500
In-Reply-To: <20071211154222.0aec68fc@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Tue, 11 Dec 2007 15:42:22 -0800

> Perhaps we should change the warning to identify the guilty device.

Applied.

Stephen, you often don't supply a proper signoff line
for one-off changes like this and I find it very irritating.
It doesn't cost you anything to hit one or two keys in your
outgoing email editor to include the signoff line.

So please do so, or I'll silently drop patches without them
in the future.

Thanks.
