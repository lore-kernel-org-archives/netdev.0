From: Alan Cox <alan@redhat.com>
Subject: Re: [patch 04/13] 8390: Split 8390 support into a pausing and a non pausing driver core
Date: Tue, 10 Jun 2008 04:55:31 -0400
Message-ID: <20080610085531.GA12300@devserv.devel.redhat.com>
References: <200806092333.m59NXnTe014676@imap1.linux-foundation.org> <20080610005247.6230fec1@core> <20080609171532.32eb5a95.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, jeff@garzik.org,
	netdev@vger.kernel.org, alan@redhat.com, randy.dunlap@oracle.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:48596 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750953AbYFJIz4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jun 2008 04:55:56 -0400
Content-Disposition: inline
In-Reply-To: <20080609171532.32eb5a95.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 09, 2008 at 05:15:32PM -0700, Andrew Morton wrote:
> This patch sat in my tree for weeks causing build errors, then Randy
> sent a fix and after that it didn't cause any build errors any more.
> 
> I do not know what typo you are referring to.

When it was proposed I NAKked it and sent an alternate patch. When you
merged it I did the same. I hadn't realised that you never got those.

Anyway the diff you've sent needs fixing before it can be merged so NAK


