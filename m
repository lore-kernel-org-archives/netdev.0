From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] NET: [CORE] Stack changes to add multiqueue
 hardware support API
Date: Thu, 28 Jun 2007 16:31:00 -0700 (PDT)
Message-ID: <20070628.163100.58439456.davem@davemloft.net>
References: <4684258D.7000503@trash.net>
	<D5C1322C3E673F459512FB59E0DDC32903220B8D@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, jeff@garzik.org, netdev@vger.kernel.org,
	auke-jan.h.kok@intel.com, hadi@cyberus.ca
To: peter.p.waskiewicz.jr@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49652
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753786AbXF1Xao (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2007 19:30:44 -0400
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC32903220B8D@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Date: Thu, 28 Jun 2007 16:08:43 -0700

> Thanks Patrick for taking care of this.  I am totally fine with this
> patch; if anyone else has feedback, please send it.  If not, I'm excited
> to see if these can be considered for 2.6.23 now.  :)  Thanks everyone
> for the help.

I'll look over the current patches later this evening, I was
initially waiting for the GSO BUG() akpm reported to get fixed
and Herbert took care of that an hour or so ago.
