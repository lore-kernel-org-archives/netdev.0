From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 4/6] 8390: Split 8390 support into a pausing and a non
 pausing driver core
Date: Fri, 4 Jul 2008 01:52:16 -0700
Message-ID: <20080704015216.7edfab57.akpm@linux-foundation.org>
References: <200807040643.m646hCdF017240@imap1.linux-foundation.org>
	<20080704092623.2b254997@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, alan@redhat.com,
	randy.dunlap@oracle.com
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:34964 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751525AbYGDIxh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jul 2008 04:53:37 -0400
In-Reply-To: <20080704092623.2b254997@lxorguk.ukuu.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 4 Jul 2008 09:26:23 +0100 Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:

> > [randy.dunlap@oracle.com: ne2 (MCA) needs both 8390.o and 8390p.o functions]
> 
> That comment is wrong - the code is now correct but not the comment

OK, I am officially fed up with trying to get that patch into working
shape.  I dropped it.

