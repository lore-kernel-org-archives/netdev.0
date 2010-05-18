From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 0/6] netns support in the kobject layer
Date: Mon, 17 May 2010 21:08:44 -0700
Message-ID: <20100518040844.GB19928@kroah.com>
References: <20100517181133.GB18721@kroah.com> <m1zkzyfdob.fsf@fess.ebiederm.org> <20100517210318.GA6170@suse.de> <20100517.164821.189684939.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gregkh@suse.de, ebiederm@xmission.com, kay.sievers@vrfy.org,
	linux-kernel@vger.kernel.org, tj@kernel.org,
	cornelia.huck@de.ibm.com, eric.dumazet@gmail.com, bcrl@lhnet.ca,
	serue@us.ibm.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:39497 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751089Ab0EREUC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 May 2010 00:20:02 -0400
Content-Disposition: inline
In-Reply-To: <20100517.164821.189684939.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 17, 2010 at 04:48:21PM -0700, David Miller wrote:
> From: Greg KH <gregkh@suse.de>
> Date: Mon, 17 May 2010 14:03:18 -0700
> 
> > On Mon, May 17, 2010 at 01:58:44PM -0700, Eric W. Biederman wrote:
> >> Greg KH <greg@kroah.com> writes:
> >> 
> >> If I must I will resend these, but these patches are already in
> >> production use, and I had them to you weeks before the merge window
> >> closed.
> > 
> > Yes, but they were not reviewed by the network maintainer until after
> > the merge window closed.  I already have your sysfs-namespace patches
> > queued up for .35, and that's a big enough change for me to feel
> > comfortable with at the moment.
> 
> Greg, this is complete bullshit.

"complete bullshit"?  How about just a "little bullshit" :)

> I reviewed them last week, they are fine
> and have been around forever.
> 
> Merge them in now, making them wait until 2.6.36 is completely rediculious.

Ok, as they are primarily affecting your subsystem, if you don't object,
I'll queue them up to my tree tomorrow and push them to Linus within
this merge period.

thanks,

greg k-h
