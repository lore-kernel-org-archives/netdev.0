From: Dave Jones <davej@redhat.com>
Subject: Re: [0/4] trivial cleanups for via-velocity.c
Date: Tue, 21 Jul 2009 15:27:42 -0400
Message-ID: <20090721192741.GA3831@redhat.com>
References: <200907211640.n6LGeG5d011439@gelk.kernelslacker.org> <20090721.111235.211304996.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:41997 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752469AbZGUT1q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jul 2009 15:27:46 -0400
Content-Disposition: inline
In-Reply-To: <20090721.111235.211304996.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 21, 2009 at 11:12:35AM -0700, David Miller wrote:
 > From: Dave Jones <davej@redhat.com>
 > Date: Mon, 20 Jul 2009 23:34:56 -0400
 > 
 > > I've had these sitting around for a while, they should be safe to apply.
 > > I checked a diff of the disassembly from objdump before/after, and
 > > the only diffs were the placement of the functions & jump offsets changing
 > > due to the reordering in diff 3/4.
 > 
 > These do not apply to the driver in the current tree, particularly
 > it doesn't apply at all to net-next-2.6 which is where I would
 > add this.
 > 
 > Please fix this up and resubmit, thanks.

Actually only 1/4 needs rediffing. It removes the only line that changes
in via-velocity in net-next.  I'll send a rediff.

thanks,

	Dave

