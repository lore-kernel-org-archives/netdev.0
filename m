From: David Brownell <david-b@pacbell.net>
Subject: Re: PATCH: usbnet: doc updates
Date: Sun, 5 Sep 2010 21:38:15 -0700 (PDT)
Message-ID: <872911.25174.qm@web180305.mail.gq1.yahoo.com>
References: <20100905.171227.193704987.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux@rainbow-software.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from n1-vm1.bullet.mail.gq1.yahoo.com ([67.195.23.153]:26421 "HELO
	n1-vm1.bullet.mail.gq1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750775Ab0IFEiR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Sep 2010 00:38:17 -0400
In-Reply-To: <20100905.171227.193704987.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



--- On Sun, 9/5/10, David Miller <davem@davemloft.net> wrote:

> > Apologies in advance for sending this as an
> > attachment, but I think it's less likely to get
> > angled (except quoted-printable?) this way.
> 
> Well, patchwork didn't grok it at all, and this means your
> patch is a
> lot more work for me.

More than having to fix up a patch that's had
tabs morphed to spaces, and line-endings broken?

I'm sending a new version in a followup, direct
to you (and list) which I hope will be easier to
cope with.


> 
> Actually looking at the patch, the comment formatting is
> not all
> that pretty:
> 
> + * Note that the design center for usbnet has one IEEE
> packet per URB, and
> +maps network TX and RX queues directly to the USB hardware
> TX/RX queues,
> 
> Please start every line of the comment with the
> proper leading " * " rather than going straight to
> the text.
> 

I guess you don't like



