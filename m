From: Joe Perches <joe@perches.com>
Subject: Re: [Suggestion] ISDN: isdnloop: C grammar issue, '}' miss match
 'if' and 'switch' statement.
Date: Thu, 04 Apr 2013 20:00:24 -0700
Message-ID: <1365130824.25884.8.camel@joe-AO722>
References: <1364999477.13853.21.camel@edumazet-glaptop>
	 <CA+55aFw+Efs+um15_V6t-9rXd-U1VJS9p+_6E-m5jr87h-BPVg@mail.gmail.com>
	 <515D3A09.7040202@asianux.com>
	 <20130404.140956.2233513394092413594.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: gang.chen@asianux.com, torvalds@linux-foundation.org,
	eric.dumazet@gmail.com, mkubecek@suse.cz, fengguang.wu@intel.com,
	isdn@linux-pingi.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:51929 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1161036Ab3DEDA0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Apr 2013 23:00:26 -0400
In-Reply-To: <20130404.140956.2233513394092413594.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-04-04 at 14:09 -0400, David Miller wrote:
> From: Chen Gang <gang.chen@asianux.com>
> Date: Thu, 04 Apr 2013 16:30:01 +0800
> >> Of course, nobody sane actually cares about ISDN any more, so I think
> >> this is all pretty academic. I think even Germany (where ISDN *used*
> >> to be very common due to telephone monopolies and odd rules) no longer
> >> uses it. I can't imagine that anybody else does either.
> >   can we delete it ?
> I think the point is no that we can delete it, but rather that we
> should concentrate our efforts on code that more people use rather
> than trying to clean up antiquated code with very few users.

Very sensible.

I was going to see about moving drivers/isdn/hardware/eicon
to staging but it seems the hardware is still for sale.

http://www.dialogic.com/en/products/media/diva/diva-bri-2.aspx

Anyone have suggestions on other obsolete isdn drivers that
could be moved to staging for awhile before deletion?
