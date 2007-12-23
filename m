From: Al Viro <viro@ftp.linux.org.uk>
Subject: Re: [git patches] net driver fixes
Date: Sun, 23 Dec 2007 07:02:23 +0000
Message-ID: <20071223070223.GQ8181@ftp.linux.org.uk>
References: <20071223053314.GA31966@havoc.gtf.org> <20071223062731.GP8181@ftp.linux.org.uk> <476E0346.1030902@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:45333 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751352AbXLWHC2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Dec 2007 02:02:28 -0500
Content-Disposition: inline
In-Reply-To: <476E0346.1030902@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 23, 2007 at 01:42:14AM -0500, Jeff Garzik wrote:
> I applied it to #upstream (2.6.25) since forcedeth is not on any 
> big-endian platforms AFAIK.

All right, then...  I hadn't been sure if it's onboard-only, that's all.
 
> I have an epic100 card too if you need it (though it sounds like you 
> have something testable).

Picked one for a fiver on ebay, just need to get around to putting it
into that U60 box and testing; not a problem, just hadn't got around to
doing that yet.
