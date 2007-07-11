From: Jiri Kosina <jikos@jikos.cz>
Subject: Re: [git patches] net driver updates
Date: Wed, 11 Jul 2007 11:34:19 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0707111128330.31463@twin.jikos.cz>
References: <20070710183953.GA8898@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Chris Stromsoe <cbs@cts.ucla.edu>,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from twin.jikos.cz ([213.151.79.26]:36290 "EHLO twin.jikos.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758253AbXGKJej (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jul 2007 05:34:39 -0400
In-Reply-To: <20070710183953.GA8898@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 10 Jul 2007, Jeff Garzik wrote:

> Various minor updates.  The only thing of note is sk98lin driver removal.
> Please pull from 'upstream-linus' branch of
> master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-linus

This is probably going to cause a new entry in regressions list, as at 
least Chris Stromsoe has reported bonding-related problems with skge that 
don't happen with sklin - 
http://www.uwsg.indiana.edu/hypermail/linux/kernel/0707.1/1158.html

-- 
Jiri Kosina
