From: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Subject: Re: [Xen-devel] [PATCH 1/3] xen-netback: fix license ident used in
 MODULE_LICENSE
Date: Fri, 22 Jan 2016 20:25:21 +0000
Message-ID: <20160122202521.76b98494@lxorguk.ukuu.org.uk>
References: <1453466057-7176-1-git-send-email-wei.liu2@citrix.com>
	<1453466057-7176-2-git-send-email-wei.liu2@citrix.com>
	<56A22B30.3020206@citrix.com>
	<20160122134943.GB1691@citrix.com>
	<1453472147.4320.92.camel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Xen-devel <xen-devel@lists.xenproject.org>,
	"open list:XEN NETWORK BACKEND DRIVER" <netdev@vger.kernel.org>,
	open list <linux-kernel@vger.kernel.org>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>
To: Ian Campbell <ian.campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lxorguk.ukuu.org.uk ([81.2.110.251]:32968 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752552AbcAVUZf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2016 15:25:35 -0500
In-Reply-To: <1453472147.4320.92.camel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The fact what include/linux/license.h:license_is_gpl_compatible includes
> "Dual MIT/GPL" as an option seems to suggest that it is enough of a thing
> to be validly used as the contents of a MODULE_LICENSE() thing.

Yes. The MIT licence most definitely exists, and people know what it
means.

Also nobody should be changing the licence on anything unless they have
the written permission of all rights holders on record, so it's best to
leave it be 8)

Alan
