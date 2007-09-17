From: David Miller <davem@davemloft.net>
Subject: Re: net-2.6.24 plans
Date: Mon, 17 Sep 2007 09:22:38 -0700 (PDT)
Message-ID: <20070917.092238.78709262.davem@davemloft.net>
References: <20070916.202258.03371690.davem@davemloft.net>
	<46EDFE40.5060306@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59141
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752027AbXIQQWj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2007 12:22:39 -0400
In-Reply-To: <46EDFE40.5060306@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jeff@garzik.org>
Date: Mon, 17 Sep 2007 00:10:40 -0400

> David Miller wrote:
> > We've touched so much in net-2.6.24 that we really should be auditing
> > the thing and fixing any bugs that have been added.  If you're bored
> > and looking for something to do, pick an odd NAPI driver and audit it
> > in the net-2.6.24 tree.
> 
> You could try that weird "post patches on the list" thing for review.
> 
> I dunno about sparc64, but IMO any networking work you do yourself and 
> commit yourself should also be sent to the list for review.

I sent every single revision of the NAPI struct patch to netdev
Jeff.
