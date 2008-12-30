From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [7/7] dst: kconfig and makefile changes.
Date: Wed, 31 Dec 2008 00:21:16 +0300
Message-ID: <20081230212116.GB20238@ioremap.net>
References: <1230292576-23963-1-git-send-email-zbr@ioremap.net> <1230292576-23963-2-git-send-email-zbr@ioremap.net> <1230292576-23963-3-git-send-email-zbr@ioremap.net> <1230292576-23963-4-git-send-email-zbr@ioremap.net> <1230292576-23963-5-git-send-email-zbr@ioremap.net> <1230292576-23963-6-git-send-email-zbr@ioremap.net> <1230292576-23963-7-git-send-email-zbr@ioremap.net> <1230292576-23963-8-git-send-email-zbr@ioremap.net> <20081230092628.16662796.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, dst@ioremap.net,
	netdev@vger.kernel.org
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kandzendo.ru ([195.178.208.66]:58014 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752400AbYL3VVT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Dec 2008 16:21:19 -0500
Content-Disposition: inline
In-Reply-To: <20081230092628.16662796.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 30, 2008 at 09:26:28AM -0800, Randy Dunlap (randy.dunlap@oracle.com) wrote:
> > +	---help---
> > +	DST is a network block device storage, which can be used to organize
> > +	exported storages on the remote nodes into the local block device.
> > +
> > +	DST is a network block device storage, which can be used to organize
> > +	exported storages on the remote nodes into the local block device.
> > +
> (I thought that I had already reported this...)
> 
> Above paragraph is duplicated.  Also, "storages" isn't proper AFAIK.
> Just use "storage".

Nope :)

Thanks a lot Randy, I will fix the spelling.

-- 
	Evgeniy Polyakov
