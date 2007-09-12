From: David Miller <davem@davemloft.net>
Subject: Re: New NAPI API: Need for netif_napi_remove() ?!
Date: Wed, 12 Sep 2007 07:29:26 -0700 (PDT)
Message-ID: <20070912.072926.02282823.davem@davemloft.net>
References: <46E5DECE.30206@intel.com>
	<46E5E0F5.6080607@foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, shemminger@osdl.org,
	peter.p.waskiewicz.jr@intel.com, jesse.brandeburg@intel.com,
	netdev@vger.kernel.org
To: sofar@foo-projects.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:51233
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S966588AbXILO3c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 10:29:32 -0400
In-Reply-To: <46E5E0F5.6080607@foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Kok, Auke" <sofar@foo-projects.org>
Date: Mon, 10 Sep 2007 17:27:33 -0700

> hm, I spoke too soon, I think I can get by for now by just modifying 
> adapter->napi.poll when needed, and this would be clean enough for now. This 
> might change as I enable multiqueue in this driver later though.

Ok, let me know if things change.

The only reason it doesn't exist was the lack of any need.
