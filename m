From: David Miller <davem@davemloft.net>
Subject: Re: [patch 6/7] hci_ldisc: fix null pointer deref
Date: Tue, 05 Feb 2008 03:11:29 -0800 (PST)
Message-ID: <20080205.031129.40584551.davem@davemloft.net>
References: <200802050748.m157m0ne010461@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: marcel@holtmann.org, netdev@vger.kernel.org, david@davidnewall.com,
	alan@lxorguk.ukuu.org.uk, arjan@linux.intel.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35633
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756587AbYBELLB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 06:11:01 -0500
In-Reply-To: <200802050748.m157m0ne010461@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Mon, 04 Feb 2008 23:48:18 -0800

> akpm:
> 
>   No idea.  trollmerge.
> 
> Cc: Arjan van de Ven <arjan@linux.intel.com>
> Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>
> Cc: Marcel Holtmann <marcel@holtmann.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

I'll let Marcel and/or Alan take a look at this one.
