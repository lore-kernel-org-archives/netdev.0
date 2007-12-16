From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: assign random address
Date: Sun, 16 Dec 2007 15:40:18 -0800 (PST)
Message-ID: <20071216.154018.156758308.davem@davemloft.net>
References: <20071216142915.c120d25c.akpm@linux-foundation.org>
	<20071216.152606.35263254.davem@davemloft.net>
	<20071216153442.a11e2e1f.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, berrange@redhat.com,
	jeff@garzik.org, herbert@gondor.apana.org.au, rjw@sisk.pl
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42275
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758199AbXLPXk0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Dec 2007 18:40:26 -0500
In-Reply-To: <20071216153442.a11e2e1f.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Sun, 16 Dec 2007 15:34:42 -0800

> Take a look at the git logs, see what most other people are doing.

You're talking bucking a convention that has been used
for all networking changes since we starting using real
revision control.

I've shown how the subject lines can be done in a way
that both satisfies the scripts you're worried about
and keeps the networking changes looking the way they
have for 5+ years.

What's the reason to change again?
