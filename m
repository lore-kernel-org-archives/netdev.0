From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [PATCH 1/3] xen-netback: fix license ident used in
 MODULE_LICENSE
Date: Sat, 23 Jan 2016 14:54:38 +0000
Message-ID: <20160123145438.GB9393@citrix.com>
References: <1453466057-7176-1-git-send-email-wei.liu2@citrix.com>
 <1453466057-7176-2-git-send-email-wei.liu2@citrix.com>
 <56A22B30.3020206@citrix.com> <20160122134943.GB1691@citrix.com>
 <1453472147.4320.92.camel@citrix.com>
 <20160122202521.76b98494@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Xen-devel <xen-devel@lists.xenproject.org>,
	"open list:XEN NETWORK BACKEND DRIVER" <netdev@vger.kernel.org>,
	open list <linux-kernel@vger.kernel.org>,
	"Boris Ostrovsky" <boris.ostrovsky@oracle.com>
To: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:62916 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754051AbcAWOyk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jan 2016 09:54:40 -0500
Content-Disposition: inline
In-Reply-To: <20160122202521.76b98494@lxorguk.ukuu.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 22, 2016 at 08:25:21PM +0000, One Thousand Gnomes wrote:
> > The fact what include/linux/license.h:license_is_gpl_compatible includes
> > "Dual MIT/GPL" as an option seems to suggest that it is enough of a thing
> > to be validly used as the contents of a MODULE_LICENSE() thing.
> 
> Yes. The MIT licence most definitely exists, and people know what it
> means.
> 
> Also nobody should be changing the licence on anything unless they have
> the written permission of all rights holders on record, so it's best to
> leave it be 8)
> 

I knew from the beginning anything related to license will be fun. :-)

In this particular case, I don't think I need to get confirmation from
all rights holder because they've agreed to the licenses listed in
the comment. I'm merely fixing a bug in code.

I understand people have different opinion on how this should be
interpreted. And I'm not a lawyer. Let's just leave it be now and divert
our energy to more useful things in life.

Wei.

> Alan
