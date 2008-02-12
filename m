From: Ben Dooks <ben-linux@fluff.org>
Subject: Re: [git patches] net driver updates
Date: Tue, 12 Feb 2008 12:38:28 +0000
Message-ID: <20080212123828.GB26519@fluff.org.uk>
References: <20080211170516.GA13872@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Laurent Pinchart <laurentp@cse-semaphore.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:61336 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751661AbYBLMip (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2008 07:38:45 -0500
Content-Disposition: inline
In-Reply-To: <20080211170516.GA13872@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 11, 2008 at 12:05:16PM -0500, Jeff Garzik wrote:
> Mostly fixes, a few cleanups (generally assisting fixes), and an
> exception for PS3 wireless because it had been posted, reviewed and
> acked for a while, just not committed.

Thanks, good to get the DM9000 changes moving.
 
> Please pull from 'upstream-davem' branch of
> master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-davem
> 

> Ben Dooks (24):
>       DM9000: Fix endian-ness of data accesses.
>       DM9000: Add platform data to specify external phy

These two where meant to be from Laurent Pinchart, they do have
the correct signed-off lines in for him and start with "Patch from:". Is
there any chance of fixing the authour attribution now?

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
