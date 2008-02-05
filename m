From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [patch 6/7] hci_ldisc: fix null pointer deref
Date: Tue, 05 Feb 2008 17:51:07 +0100
Message-ID: <1202230268.15090.105.camel@violet>
References: <200802050748.m157m0ne010461@imap1.linux-foundation.org>
	 <20080205.031129.40584551.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	david@davidnewall.com, alan@lxorguk.ukuu.org.uk,
	arjan@linux.intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:47750 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750861AbYBEQuk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 11:50:40 -0500
In-Reply-To: <20080205.031129.40584551.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

> > akpm:
> > 
> >   No idea.  trollmerge.
> > 
> > Cc: Arjan van de Ven <arjan@linux.intel.com>
> > Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>
> > Cc: Marcel Holtmann <marcel@holtmann.org>
> > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> 
> I'll let Marcel and/or Alan take a look at this one.

we might have to re-work the whole hci_uart driver at some point, but
for now I think this fix is feasible.

Alan, if you think it is wrong please step up. I am not an expert when
it comes to TTY line disciplines.

Regards

Marcel


