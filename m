From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: Re: linux-next: net tree build failure
Date: Mon, 11 Jan 2010 11:16:32 +0000 (GMT)
Message-ID: <alpine.LFD.2.00.1001111116070.29332@eddie.linux-mips.org>
References: <20100111184205.8d53fe5b.Stephen@Rothwell.id.au>         <20100111.000205.164473435.davem@davemloft.net> <1263197772.1907.44.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, Stephen@Rothwell.id.au,
	netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	H Hartley Sweeten <hartleys@visionengravers.com>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753266Ab0AKLQf@vger.kernel.org>
In-Reply-To: <1263197772.1907.44.camel@Joe-Laptop.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 11 Jan 2010, Joe Perches wrote:

> Perhaps it'd be better to kill off the use of bitrev in
> lib/vsprintf as Maciej thinks it broken.
> 
> Maybe use something like this?

 Thanks for fixing it.

  Maciej
