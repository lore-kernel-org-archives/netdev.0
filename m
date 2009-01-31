From: Parag Warudkar <parag.lkml@gmail.com>
Subject: Re: 2.6.29-rc3: tg3 dead after resume
Date: Fri, 30 Jan 2009 20:54:38 -0500 (EST)
Message-ID: <alpine.DEB.2.00.0901302051390.5643@parag-desktop>
References: <alpine.DEB.2.00.0901281858380.5048@parag-desktop> <200901310059.17746.rjw@sisk.pl> <alpine.DEB.2.00.0901301924550.5056@parag-desktop> <200901310138.51214.rjw@sisk.pl> <alpine.DEB.2.00.0901302016170.5643@parag-desktop>
 <alpine.LFD.2.00.0901301741380.3150@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Parag Warudkar <parag.lkml@gmail.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Matt Carlson <mcarlson@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.30]:13448 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751387AbZAaByn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2009 20:54:43 -0500
In-Reply-To: <alpine.LFD.2.00.0901301741380.3150@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Fri, 30 Jan 2009, Linus Torvalds wrote:

> 
> 
> On Fri, 30 Jan 2009, Parag Warudkar wrote:
> > 
> > Excellent! This patch works - tg3 comes back and gets link after resume.
> 
> I still think the patch isn't very good. See my previous email. 

Ok - I will run with it temporarily and will do what I can to track down 
what was wrong with the legacy PM.

Thanks!
Parag

