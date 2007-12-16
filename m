From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] bridge: assign random address
Date: Sun, 16 Dec 2007 15:46:21 -0800
Message-ID: <20071216154621.c7e2a3e9.akpm@linux-foundation.org>
References: <20071216142915.c120d25c.akpm@linux-foundation.org>
	<20071216.152606.35263254.davem@davemloft.net>
	<20071216153442.a11e2e1f.akpm@linux-foundation.org>
	<20071216.154018.156758308.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, berrange@redhat.com,
	jeff@garzik.org, herbert@gondor.apana.org.au, rjw@sisk.pl
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:50438 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758199AbXLPXry (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Dec 2007 18:47:54 -0500
In-Reply-To: <20071216.154018.156758308.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 16 Dec 2007 15:40:18 -0800 (PST) David Miller <davem@davemloft.net> wrote:

> From: Andrew Morton <akpm@linux-foundation.org>
> Date: Sun, 16 Dec 2007 15:34:42 -0800
> 
> > Take a look at the git logs, see what most other people are doing.
> 
> You're talking bucking a convention that has been used
> for all networking changes since we starting using real
> revision control.
> 
> I've shown how the subject lines can be done in a way
> that both satisfies the scripts you're worried about
> and keeps the networking changes looking the way they
> have for 5+ years.
> 
> What's the reason to change again?

I see no particular reason to change - it's just one of those things.

Two third of commits don't use [subsystem] and 90% don't use trailing
period.  Reasons to change would be a) consistency and b) the time it takes
to occasionally fix up patches which use [subsystem] as I earlier
described.

I don't think these are terribly important, really.
