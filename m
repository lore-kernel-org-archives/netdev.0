From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH/RFC] remove irqs_disabled warning from local_bh_enable
Date: Fri, 27 Jun 2008 12:53:29 +0200
Message-ID: <20080627105329.GA11218@elte.hu>
References: <1213739834.3803.137.camel@johannes.berg> <20080620155541.GC6656@elte.hu> <200806201801.09858.mb@bu3sch.de> <200806201818.34904.mb@bu3sch.de> <20080623084123.GA32688@elte.hu> <48647B94.5000006@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Buesch <mb@bu3sch.de>,
	Johannes Berg <johannes@sipsolutions.net>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Linux Kernel list <linux-kernel@vger.kernel.org>,
	David Ellingsworth <david@identd.dyndns.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:34773 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752605AbYF0Kyl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jun 2008 06:54:41 -0400
Content-Disposition: inline
In-Reply-To: <48647B94.5000006@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Jeff Garzik <jgarzik@pobox.com> wrote:

> applied

track record of 4 days of testing: the warning indeed went away and no 
other funnies in this area happened on that box. Thanks,

	Ingo
