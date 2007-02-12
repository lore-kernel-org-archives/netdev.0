From: Andi Kleen <ak@suse.de>
Subject: Re: NetXen driver name
Date: Mon, 12 Feb 2007 09:47:38 +0100
Message-ID: <200702120947.38891.ak@suse.de>
References: <200702082152.19772.amitkale@netxen.com> <200702120912.56487.ak@suse.de> <200702121358.34712.amitkale@netxen.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Amit Kale <amitkale@netxen.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:53163 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932946AbXBLIrm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Feb 2007 03:47:42 -0500
In-Reply-To: <200702121358.34712.amitkale@netxen.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 12 February 2007 09:28, Amit Kale wrote:
> On Monday 12 February 2007 13:42, Andi Kleen wrote:
> > On Monday 12 February 2007 09:03, Amit Kale wrote:
> > > The already released kernel contains a broken driver.  It broke due to
> > > some code rearrangement changes someone submitted to fix sparse warnings.
> >
> > You mean it doesn't compile?
> 
> It compiles, but doesn't work if tried on real hardware.
> We'll send a fix for the same in a few hours.

But didn't the driver make it into distributions with the old name? 
That could be another compat issue (such things easily make unhappy
users and you probably wouldn't like that)

But ok then a rename is probably still possible. You have to ask Jeff of course.

-Andi
