From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/4] drivers/atm/firestream.c: suppress uninitialized
 var warning
Date: Fri, 28 Mar 2008 17:35:23 -0700 (PDT)
Message-ID: <20080328.173523.66723417.davem@davemloft.net>
References: <20080328165437.bfd7726c.akpm@linux-foundation.org>
	<20080328.165812.253071507.davem@davemloft.net>
	<20080328171128.ff03ec02.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chas@cmf.nrl.navy.mil, jeff@garzik.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37187
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754112AbYC2AfX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 20:35:23 -0400
In-Reply-To: <20080328171128.ff03ec02.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Fri, 28 Mar 2008 17:11:28 -0700

> Plus uninitialized_var() gives us something to grep for and
> experiment with if/when future gcc's get smarter.

That's sounds like a great investment of your time.

I guess there aren't any more interesting things to work
on, nor bugs to fix.
