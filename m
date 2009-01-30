From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: 2.6.29-rc3: tg3 dead after resume
Date: Fri, 30 Jan 2009 15:07:30 -0800 (PST)
Message-ID: <alpine.LFD.2.00.0901301506520.3150@localhost.localdomain>
References: <alpine.DEB.2.00.0901281858380.5048@parag-desktop> <200901300110.56533.rjw@sisk.pl> <alpine.DEB.2.00.0901301730230.6574@parag-desktop> <200901302354.27497.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Parag Warudkar <parag.lkml@gmail.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:57920 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755684AbZA3XHx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2009 18:07:53 -0500
In-Reply-To: <200901302354.27497.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Fri, 30 Jan 2009, Rafael J. Wysocki wrote:
>
> Well, I'm not sure if tg3 is at fault, really.
> 
> What happens if you unload tg3 before suspend and load it back after the
> resume?

Yes, good thing to test. See my previous email - maybe it's a bridge.

		Linus
