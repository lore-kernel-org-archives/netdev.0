From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: blackfin drivers/net/smc91x.c build error
Date: Tue, 10 Jun 2008 20:47:19 -0700 (PDT)
Message-ID: <alpine.LFD.1.10.0806102046450.3101@woody.linux-foundation.org>
References: <20080606162212.GC2201@cs181133002.pp.htv.fi>  <8bd0f97a0806061252n1cf5ee33i40ddf9f55588e242@mail.gmail.com>  <20080610135349.GA30792@cs181133002.pp.htv.fi>  <8bd0f97a0806101013w42b9028j5dfa38d654f3d05f@mail.gmail.com>  <20080610173450.GC11685@cs181133002.pp.htv.fi>
 <386072610806102037u39ec18e6ye26ef184d6a9516e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Adrian Bunk <bunk@kernel.org>,
	Mike Frysinger <vapier.adi@gmail.com>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Bryan Wu <cooloney@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:60640 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755467AbYFKDsJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2008 23:48:09 -0400
In-Reply-To: <386072610806102037u39ec18e6ye26ef184d6a9516e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Wed, 11 Jun 2008, Bryan Wu wrote:
> 
> Linus, could you please revert it?
> 099c736a470c8080a166e7a089f1e48e15f9947c
> Or I send a patch out to revert it?

I'd like to see a patch, since by now I'm confused by this all whether 
it's a straight revert or if there's a fix.

			Linus
