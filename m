From: David Miller <davem@davemloft.net>
Subject: Re: Tc filtering: broken 802_3 classifier?
Date: Wed, 25 Jul 2007 17:10:47 -0700 (PDT)
Message-ID: <20070725.171047.28818312.davem@davemloft.net>
References: <D5C1322C3E673F459512FB59E0DDC329034BFCD2@orsmsx414.amr.corp.intel.com>
	<46A7DF75.5090609@trash.net>
	<46A7E3BE.8090301@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38406
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751915AbXGZAKs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2007 20:10:48 -0400
In-Reply-To: <46A7E3BE.8090301@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 26 Jul 2007 01:58:54 +0200

> This patch should fix it, but other qdiscs might need similar
> fixes I believe. I'll look into that tommorrow.

Thanks for figuring this out Patrick, let me know when you
have a final version to apply.
