From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] bridge: assign random address
Date: Sun, 16 Dec 2007 14:29:15 -0800
Message-ID: <20071216142915.c120d25c.akpm@linux-foundation.org>
References: <20071211145243.66e1f66a@freepuppy.rosehill>
	<20071211145921.11094ab8.akpm@linux-foundation.org>
	<20071211154835.75ace6bc@freepuppy.rosehill>
	<20071216.133717.202852113.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, berrange@redhat.com,
	jeff@garzik.org, herbert@gondor.apana.org.au, rjw@sisk.pl
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:48718 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1765600AbXLPWaw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Dec 2007 17:30:52 -0500
In-Reply-To: <20071216.133717.202852113.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 16 Dec 2007 13:37:17 -0800 (PST) David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@linux-foundation.org>
> Date: Tue, 11 Dec 2007 15:48:35 -0800
> 
> > Subject: Re: [PATCH] bridge: assign random address
> 
> "bridge" should all-caps and in brackets,

No, "bridge" should not be in [].  Lots of people's patch-receiving scripts
assume that any text in [] is to be removed as the patch is committed.  It
contains text which is only relevant to the particular email which carried
the patch.  Stuff like "patch" and "4/5" and "linux-2.6.23", etc.

> "assign random address"
> should be capitalized like a proper english sentence with a period at
> the end.

Actually I usually remove the caps and the waste-of-space period, but
that's much less important than the brackets abuse.  The bracket convention
is quite useful and I've often wondered why I need to edit the patch title
when I merge up patches from net developers ;)

