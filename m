From: David Miller <davem@davemloft.net>
Subject: Re: [PANIC] lro + iscsi or lro + skb text search causes panic
Date: Sun, 25 Jan 2009 21:32:22 -0800 (PST)
Message-ID: <20090125.213222.192571170.davem@davemloft.net>
References: <alpine.WNT.2.00.0901221234420.4188@jbrandeb-desk1.amr.corp.intel.com>
	<20090122232131.GA22771@gondor.apana.org.au>
	<4979097B.4040108@cs.wisc.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, jesse.brandeburg@intel.com,
	netdev@vger.kernel.org, olaf.kirch@oracle.com, tgraf@suug.ch,
	kkeil@suse.de
To: michaelc@cs.wisc.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51165
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750744AbZAZFcT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2009 00:32:19 -0500
In-Reply-To: <4979097B.4040108@cs.wisc.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Christie <michaelc@cs.wisc.edu>
Date: Thu, 22 Jan 2009 18:04:11 -0600

> With the patch running against linus's git tree, my box locks
> up. You cannot ping it. I do not get a oops or anything in the logs,
> and the keyboard does not respond. I will try to get some oops
> output and more info.

Herbert, any idea offhand?
