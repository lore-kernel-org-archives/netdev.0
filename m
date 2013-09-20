From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [patch 2/4] mISDN: add support for group membership check
Date: Fri, 20 Sep 2013 17:30:44 +0100
Message-ID: <20130920163043.GN7729@decadent.org.uk>
References: <523C7464.3070007@suse.cz>
 <20130920.121535.1653382964468102292.davem@davemloft.net>
 <523C753A.8040401@suse.cz>
 <20130920.122142.1032350399957506112.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jslaby@suse.cz, akpm@linux-foundation.org, jeffm@suse.com,
	netdev@vger.kernel.org, isdn4linux@koppen.de, isdn@linux-pingi.de,
	sergei.shtylyov@cogentembedded.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:41376 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752261Ab3ITQax (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Sep 2013 12:30:53 -0400
Content-Disposition: inline
In-Reply-To: <20130920.122142.1032350399957506112.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 20, 2013 at 12:21:42PM -0400, David Miller wrote:
> From: Jiri Slaby <jslaby@suse.cz>
> Date: Fri, 20 Sep 2013 18:18:02 +0200
> 
> > Ok, let's leave the hole in there then.
> 
> Jiri, don't turn this on me.
> 
> The issue is not whether something needs to be fixed or not, I never
> said "don't fix this" and therefore I'd like to ask politely that you
> not make it seem like I have.
> 
> Rather, I'm saying that the implementation is terrible, sets a bad
> precendence for fixing similar problems, and therefore not is in
> a state where we can apply it.
> 
> So, I'm not saying "don't fix this", I'm saying "fix it properly."

I think Jiri's last suggestion was to add the capability check to
device renaming (which I think everyone agrees is needed) and not
to add any group identity checks for any operation.

Isn't that fixing it properly?

Ben.

-- 
Ben Hutchings
We get into the habit of living before acquiring the habit of thinking.
                                                              - Albert Camus
