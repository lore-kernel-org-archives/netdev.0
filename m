From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] cdc-ether: Assume link is up initially
Date: Sat, 16 Jan 2010 01:07:24 -0800 (PST)
Message-ID: <20100116.010724.106146285.davem@davemloft.net>
References: <1262741203.26813.58.camel@localhost>
	<1262742435.26813.61.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rjw-KKrjLPT3xs0@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1262742435.26813.61.camel@localhost>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
Date: Wed, 06 Jan 2010 01:47:15 +0000

> Mail to reporter bounces, so someone else had better check this.

I'm tossing this patch until someone can reproduce and test the
fix.

Otherwise we're just going to endlessly monkey around with this
link status issue.
