From: David Miller <davem@davemloft.net>
Subject: Re: [FIX] NET: Fix sch_api and sch_prio to properly set and detect
 the root qdisc
Date: Mon, 30 Jul 2007 17:14:12 -0700 (PDT)
Message-ID: <20070730.171412.38711276.davem@davemloft.net>
References: <46A69AE6.9030009@trash.net>
	<D5C1322C3E673F459512FB59E0DDC329034F503E@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: peter.p.waskiewicz.jr@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39084
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S939605AbXGaAOO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2007 20:14:14 -0400
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC329034F503E@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Date: Fri, 27 Jul 2007 09:22:11 -0700

> 	Are these queued for 2.6.24, or are they going to make it into
> 2.6.23?  I know you're busy with patches and NAPI, but I was
> curious.  Thanks!

I've applied both fixes and will push them into 2.6.23
