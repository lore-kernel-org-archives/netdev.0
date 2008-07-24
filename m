From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: bunch of warnings in __netif_schedule
Date: Wed, 23 Jul 2008 19:27:52 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC3290577410E@orsmsx414.amr.corp.intel.com>
References: <20080723120938.36c42453@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "Arjan van de Ven" <arjan@infradead.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:49197 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751025AbYGXC2Z convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2008 22:28:25 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20080723120938.36c42453@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Hi,

> kerneloops.org also picked up a series of warnings in
__netif_schedule:
> http://www.kerneloops.org/search.php?search=__netif_schedule

> afaics Dave is on top of most of them; just wanted to mention it here
> in case some got missed...


Dave's committed a fix to remove the warning today, commit id
5b3ab1dbd401b36ba2f9bfee2d2dae252fd62cd8 in net-2.6.

Cheers,
-PJ Waskiewicz
