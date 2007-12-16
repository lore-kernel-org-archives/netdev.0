From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH take2] [AX25] circular locking with AX25 connection
 timeout
Date: Sun, 16 Dec 2007 14:02:20 -0800 (PST)
Message-ID: <20071216.140220.163393122.davem@davemloft.net>
References: <476303C8.2060507@ccr.jussieu.fr>
	<20071215101810.GA3143@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pidoux@ccr.jussieu.fr, ralf@linux-mips.org, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42709
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759045AbXLPWCd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Dec 2007 17:02:33 -0500
In-Reply-To: <20071215101810.GA3143@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Sat, 15 Dec 2007 11:18:10 +0100

> On Fri, Dec 14, 2007 at 11:29:28PM +0100, Bernard Pidoux wrote:
> > Hi,
> >
> > This patch cancels a circular locking conflict that appeared with a timeout 
> > of an AX25 connection.
> >
> > signed off by Jarek Poplawski
> 
> One spurious space less here, and maybe a few more words to the changelog.

Patch applied, thanks Jarek.
