From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: Null dereference in uli526x_rx_packet()
Date: Sat, 27 Mar 2010 00:08:24 -0600
Message-ID: <20100327060823.GA26364@lackof.org>
References: <20090329053513.GD19602@colo.lackof.org> <20090328.235931.45430524.davem@davemloft.net> <20100207071540.GA9908@lackof.org> <20100326.202125.238456279.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: grundler@parisc-linux.org, kyle@mcmartin.ca,
	netdev@vger.kernel.org, error27@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from complete.lackof.org ([198.49.126.79]:53991 "EHLO
	complete.lackof.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750851Ab0C0GIZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Mar 2010 02:08:25 -0400
Content-Disposition: inline
In-Reply-To: <20100326.202125.238456279.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 26, 2010 at 08:21:25PM -0700, David Miller wrote:
> From: Grant Grundler <grundler@parisc-linux.org>
> Date: Sun, 7 Feb 2010 00:15:40 -0700
> 
> > On Sat, Mar 28, 2009 at 11:59:31PM -0700, David Miller wrote:
> > ...
> >> > Patch below looks right to me. Clobbering the skb is certainly wrong.
> >> > 
> >> > Acked-by: Grant Grundler <grundler@parisc-linux.org>
> >> 
> >> It looks correct to me, can we get a proper submission with
> >> signoffs etc.?
> > 
> > Dave,
> > Looks like this patch was never resubmitted.
> > 
> > Kyle, can you look at http://lists.openwall.net/netdev/2009/03/27/117
> > and resubmit the code you had then with my "Acked-by" added please?
> > 
> > Or if you don't want to touch it, let me know and I'll resurrect it.
> 
> I got tired of waiting for this resubmission (a month and a half) and
> just applied the most recent version of the patch to net-2.6.
> 
> It looked correct to me too.

Thank you!
grant
