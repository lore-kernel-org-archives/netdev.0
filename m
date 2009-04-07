From: Jesse Barnes <jbarnes@virtuousgeek.org>
Subject: Re: [GIT]: Networking
Date: Mon, 6 Apr 2009 20:24:41 -0700
Message-ID: <20090406202441.1c050ec6@hobbes>
References: <20090406.175752.236260059.davem@davemloft.net>
	<alpine.LFD.2.00.0904061824410.4010@localhost.localdomain>
	<20090406.190745.263215778.davem@davemloft.net>
	<alpine.LFD.2.00.0904061931160.4010@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound-mail-19.bluehost.com ([69.89.20.234]:51648 "HELO
	outbound-mail-19.bluehost.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751649AbZDGDYs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2009 23:24:48 -0400
In-Reply-To: <alpine.LFD.2.00.0904061931160.4010@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 6 Apr 2009 19:32:11 -0700 (PDT)
Linus Torvalds <torvalds@linux-foundation.org> wrote:

> 
> 
> On Mon, 6 Apr 2009, David Miller wrote:
> 
> > From: Linus Torvalds <torvalds@linux-foundation.org>
> > Date: Mon, 6 Apr 2009 18:25:31 -0700 (PDT)
> > > 
> > > 
> > > The sky2 driver is buggered (by the previous pull, I presume).
> > > Some PCI interaction. NULL pointer dereference at boot.
> > 
> > Fixed in the PCI tree, have you pulled that one yet?
> 
> Nobody has even _asked_ me to pull.
> 
> What's the point of having fixes available if they aren't merged?

I just pushed it into my repo today and wanted at least a day of
linux-next before asking you to pull.

-- 
Jesse Barnes, Intel Open Source Technology Center
