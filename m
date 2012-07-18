From: Paul Moore <pmoore@redhat.com>
Subject: Re: [PATCH] cipso: don't follow a NULL pointer when setsockopt() is called
Date: Wed, 18 Jul 2012 09:03:32 -0400
Message-ID: <3662157.HRkTXPOiYs@sifl>
References: <20120717210738.22790.23522.stgit@sifl> <16005876.GSA3ToWriD@sifl> <20120717.143137.1363542154253711667.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16352 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754424Ab2GRNDh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jul 2012 09:03:37 -0400
In-Reply-To: <20120717.143137.1363542154253711667.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday, July 17, 2012 02:31:37 PM David Miller wrote:
> From: Paul Moore <pmoore@redhat.com>
> Date: Tue, 17 Jul 2012 17:24:50 -0400
> 
> > David, if you don't queue this up for them, let me know and I'll resend it
> > to stable once it hits Linus' tree.
> 
> I will be sure to queue it up to -stable when I apply it, as I always
> do for appropriate patches.

Okay, thanks.  I just wanted to make sure it hit -stable one way or another.

-- 
paul moore
security and virtualization @ redhat
