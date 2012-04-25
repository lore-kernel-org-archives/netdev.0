From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] unix_diag: use netlink attribute MAX convention
Date: Wed, 25 Apr 2012 13:09:06 -0700
Message-ID: <20120425130906.7a090d22@nehalam.linuxnetplumber.net>
References: <20120425115609.4ef9ece0@nehalam.linuxnetplumber.net>
	<20120425.150716.1476178549121153876.davem@davemloft.net>
	<20120425124743.5b4fb8a3@nehalam.linuxnetplumber.net>
	<20120425.155717.2099319998110521099.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shanwei88@gmail.com, xemul@parallels.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:53750 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758345Ab2DYUJL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Apr 2012 16:09:11 -0400
In-Reply-To: <20120425.155717.2099319998110521099.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 25 Apr 2012 15:57:17 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Wed, 25 Apr 2012 12:47:43 -0700
> 
> > On Wed, 25 Apr 2012 15:07:16 -0400 (EDT)
> > David Miller <davem@davemloft.net> wrote:
> > 
> >> Either you apply them as soon as possible, or you mark them
> >> appropriately as "Changes Requested" or "Deferred" so that the
> >> submitter makes appropriate fixes you've asked for, or resubmits when
> >> it's more appropriate for the change to go in.
> >> 
> >> "Under Review" doesn't mean, "I'm waiting for a kernel release with
> >> the feature".  But that's how you use it.
> > 
> > Ok. What is the suggested tag for that.
> 
> As I said above, "Deferred", with a note sent to the submitter to resubmit
> the patch at the appropriate time.

That doesn't work, not asking original submitter to resubmit.
I tried a branch, but git doesn't like branches coming and going
on remote repos.
Probably better to just have an ephemeral iproute2-next repo on kernel.org.
