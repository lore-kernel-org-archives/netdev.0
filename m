From: David Miller <davem@davemloft.net>
Subject: Re: when having to acquire an SA, ipsec drops the packet
Date: Mon, 05 Feb 2007 13:13:47 -0800 (PST)
Message-ID: <20070205.131347.61505111.davem@davemloft.net>
References: <Pine.LNX.4.64.0702011819070.11820@d.namei>
	<20070204.205315.10325007.davem@davemloft.net>
	<1170708819.2603.369.camel@faith.austin.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, netdev@vger.kernel.org, paul.moore@hp.com,
	vyekkirala@TrustedCS.com, herbert@gondor.apana.org.au
To: latten@austin.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51927
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933428AbXBEVNs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Feb 2007 16:13:48 -0500
In-Reply-To: <1170708819.2603.369.camel@faith.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joy Latten <latten@austin.ibm.com>
Date: Mon, 05 Feb 2007 14:53:39 -0600

> I can run some tests with this patch and report any results... 

Please check out the two most recent patches I posted:

1) Updated core patch with ipv6 side added.
2) Fix for thinko noticed by Venkat.

Thanks.
