From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Wed, 06 Jun 2007 16:00:48 -0700 (PDT)
Message-ID: <20070606.160048.45742078.davem@davemloft.net>
References: <20070606.153530.48530367.davem@davemloft.net>
	<D5C1322C3E673F459512FB59E0DDC32902FC6243@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org, jeff@garzik.org,
	auke-jan.h.kok@intel.com, hadi@cyberus.ca
To: peter.p.waskiewicz.jr@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40364
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S935589AbXFFXDQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2007 19:03:16 -0400
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC32902FC6243@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Date: Wed, 6 Jun 2007 15:57:35 -0700

> 	Can we move forward on this please?  If you are comfortable
> that my patches give the kernel the ability to manage hardware
> queues sufficiently, I'd like to request that 2.6.23 be opened (wink
> wink) so I can submit the patches for inclusion to that kernel.

While I am growing in support of your changes, there are
two things:

1) I want to study them more and hear more about what Patrick has to
   say about them when he returns from his trip on Sunday

2) I don't want to open up a net-2.6.23 tree yet so that people
   concentrate on bug fixes and regressions, pick an open bug or
   regression report and help out if you want net-2.6.23 cut faster
   :-)
