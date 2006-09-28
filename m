From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: Re: [PATCH 0/1] atl1: New driver, Attansic L1 Gigabit Ethernet
Date: Thu, 28 Sep 2006 08:03:04 -0500
Message-ID: <20060928130304.GA4775@osprey.hogchain.net>
References: <20060927132119.GB11922@osprey.hogchain.net> <20060928065912.GA6647@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from imf16aec.mail.bellsouth.net ([205.152.59.64]:61152 "EHLO
	imf16aec.mail.bellsouth.net") by vger.kernel.org with ESMTP
	id S1751015AbWI1NDG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 09:03:06 -0400
Received: from ibm58aec.bellsouth.net ([70.144.210.103])
          by imf16aec.mail.bellsouth.net with ESMTP
          id <20060928130305.FAZY7969.imf16aec.mail.bellsouth.net@ibm58aec.bellsouth.net>
          for <netdev@vger.kernel.org>; Thu, 28 Sep 2006 09:03:05 -0400
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
In-Reply-To: <20060928065912.GA6647@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 28, 2006 at 08:59:12AM +0200, Francois Romieu wrote:
> Jay Cliburn <jacliburn@bellsouth.net> :
> > Apologies:  I neglected to cc netdev on the initial message.
> 
> No patch here (netdev, l-k subscribed).
> 
> Can you publish the patch somewhere ?

At 200ish kbytes, the patch was apparently too large for the lists.  The
version I sent to the lists may be found at:

ftp://hogchain.net/pub/linux/m2v/attansic/kernel_driver/obsolete/20060927_full_atl1.patch.gz

You will note that it's in a directory called "obsolete."  That's
because it is undergoing significant rework based on shemminger's
comments and other considerations.

A new version will be posted in the upcoming days.

Jay
