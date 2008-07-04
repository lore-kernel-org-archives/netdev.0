From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [patch 4/6] 8390: Split 8390 support into a pausing and a non
 pausing driver core
Date: Fri, 4 Jul 2008 09:26:23 +0100
Message-ID: <20080704092623.2b254997@lxorguk.ukuu.org.uk>
References: <200807040643.m646hCdF017240@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, akpm@linux-foundation.org,
	alan@redhat.com, randy.dunlap@oracle.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:39324 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752848AbYGDIo0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jul 2008 04:44:26 -0400
In-Reply-To: <200807040643.m646hCdF017240@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> [randy.dunlap@oracle.com: ne2 (MCA) needs both 8390.o and 8390p.o functions]

That comment is wrong - the code is now correct but not the comment

