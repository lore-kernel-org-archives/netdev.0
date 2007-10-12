From: David Miller <davem@davemloft.net>
Subject: Re: Question on TSO maximum segment sizes.
Date: Thu, 11 Oct 2007 17:22:09 -0700 (PDT)
Message-ID: <20071011.172209.26285198.davem@davemloft.net>
References: <20071011.170244.32082446.davem@davemloft.net>
	<D5C1322C3E673F459512FB59E0DDC32903C440EE@orsmsx414.amr.corp.intel.com>
	<470EBD2C.8020704@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peter.p.waskiewicz.jr@intel.com, rick.jones2@hp.com,
	netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56027
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753264AbXJLAWG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 20:22:06 -0400
In-Reply-To: <470EBD2C.8020704@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Greear <greearb@candelatech.com>
Date: Thu, 11 Oct 2007 17:17:48 -0700

> Was the auto-tuning put in after 2.6.20?  If not, has this
> been tested through a higher latency link?  Or, am I confused
> and you are talking about some other setsockopt?

It's been there for quite some time.
