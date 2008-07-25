From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 11160] New: sky2 Oops on ifconfig eth0 down
 on linux-2.6.26-git11
Date: Fri, 25 Jul 2008 01:29:39 -0700 (PDT)
Message-ID: <20080725.012939.247842088.davem@davemloft.net>
References: <bug-11160-10286@http.bugzilla.kernel.org/>
	<20080725012754.c130a09e.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	jkarlson@cc.hut.fi
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37788
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751151AbYGYI3k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2008 04:29:40 -0400
In-Reply-To: <20080725012754.c130a09e.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Fri, 25 Jul 2008 01:27:54 -0700

> 
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> On Fri, 25 Jul 2008 01:19:16 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:
> 
> > http://bugzilla.kernel.org/show_bug.cgi?id=11160
> > 
> >            Summary: sky2 Oops on ifconfig eth0 down on linux-2.6.26-git11
> 
> (it's a warning, not an oops)
 ...
> I think this is known about and is being worked on.

Yes, in fact we don't warn for this case any more in Linus's
tree, so you can safely close this.
