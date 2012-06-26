From: Greg KH <greg@kroah.com>
Subject: Re: [net] ixgbe: Do not pad FCoE frames as this can cause issues
 with FCoE DDP
Date: Tue, 26 Jun 2012 09:33:58 -0700
Message-ID: <20120626163358.GA5500@kroah.com>
References: <1340695993-1911-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <20120626.004302.1065943933933136878.davem@davemloft.net>
 <1340696850.2255.17.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, alexander.h.duyck@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	stable@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:41698 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757903Ab2FZQeA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2012 12:34:00 -0400
Content-Disposition: inline
In-Reply-To: <1340696850.2255.17.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 26, 2012 at 12:47:30AM -0700, Jeff Kirsher wrote:
> On Tue, 2012-06-26 at 00:43 -0700, David Miller wrote:
> > You can't put things like "[3.4]" unquoted into the CC: list, that's
> > not kosher and vger rejected it.
> 
> Sorry, that was what Greg told me to do.  I did not realize it needed to
> be in quotes, my bad.

Greg told you no such thing, please use real email addresses on your cc:
lines, to not do so is crazy, and to blame me is sad.

greg k-h
