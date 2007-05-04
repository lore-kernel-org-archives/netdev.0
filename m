From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPROUTE: Modify tc for new PRIO multiqueue behavior
Date: Fri, 04 May 2007 14:00:06 -0700 (PDT)
Message-ID: <20070504.140006.99457686.davem@davemloft.net>
References: <20070504130110.0694aee6@freekitty>
	<D5C1322C3E673F459512FB59E0DDC32902CA58E7@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, hadi@cyberus.ca, kaber@trash.net,
	netdev@vger.kernel.org, jgarzik@pobox.com, cramerj@intel.com,
	auke-jan.h.kok@intel.com, christopher.leech@intel.com
To: peter.p.waskiewicz.jr@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32906
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S376155AbXEDVAE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2007 17:00:04 -0400
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC32902CA58E7@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Date: Fri, 4 May 2007 13:43:43 -0700

> And if someone can explain to me why 2 months of review and scrutiny
> of these patches has shifted in another direction, I'd really like
> to understand that.

One reason is that you're sort of making it clear that this feature is
for something else.  Something that you can't disclose at this time,
which of course in and of itself is perfectly fine.

However, if you can't talk about the real motivation for this feature,
and it really doesn't stand %100 on it's own as-is without that
information (I don't think it does), trying to get this work in now
using a different premise it's a little bit dishonest.  Don't you
think?

It's also a bit unreasonable to ask the community to buy into a
technology, the real purpose of which you cannot even talk about.

I'm sure everyone is happy to reconsider this work when the real
motivation can be talked about in the open.

Thanks.
