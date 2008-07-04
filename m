From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [patch 4/6] 8390: Split 8390 support into a pausing and a non
 pausing driver core
Date: Fri, 4 Jul 2008 09:44:56 +0100
Message-ID: <20080704094456.13a1a03a@lxorguk.ukuu.org.uk>
References: <200807040643.m646hCdF017240@imap1.linux-foundation.org>
	<20080704092623.2b254997@lxorguk.ukuu.org.uk>
	<20080704015216.7edfab57.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, alan@redhat.com,
	randy.dunlap@oracle.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:52535 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750848AbYGDJDW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jul 2008 05:03:22 -0400
In-Reply-To: <20080704015216.7edfab57.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 4 Jul 2008 01:52:16 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Fri, 4 Jul 2008 09:26:23 +0100 Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:
> 
> > > [randy.dunlap@oracle.com: ne2 (MCA) needs both 8390.o and 8390p.o functions]
> > 
> > That comment is wrong - the code is now correct but not the comment
> 
> OK, I am officially fed up with trying to get that patch into working
> shape.  I dropped it.

You've got the patch in shape - just not the comment. So you've just
thrown it out rather than hitting 'dd' on a comment line that is out of
date.

Oh well.

Alan
