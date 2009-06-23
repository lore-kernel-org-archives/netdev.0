From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH v3.1415] Documentation: add documentation summary for
	rc-series and merge window
Date: Tue, 23 Jun 2009 11:37:36 -0700
Message-ID: <20090623183736.GA4928@kroah.com>
References: <20090622222217.GH23972@bombadil.infradead.org> <m3fxdqj2bz.fsf@lwn.net> <20090623175533.GK5305@mosca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jake Edge <jake@lwn.net>,
	Luis Rodriguez <Luis.Rodriguez@Atheros.com>,
	"torvalds@linux-foundation.org" <torvalds@linux-foundation.org>,
	Pavel Machek <pavel@ucw.cz>, "corbet@lwn.net" <corbet@lwn.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"alan@lxorguk.ukuu.org.uk" <alan@lxorguk.ukuu.org.uk>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"tshibata@ab.jp.nec.com" <tshibata@ab.jp.nec.com>
To: "Luis R. Rodriguez" <lrodriguez@atheros.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:50425 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754641AbZFWSmK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Jun 2009 14:42:10 -0400
Content-Disposition: inline
In-Reply-To: <20090623175533.GK5305@mosca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 23, 2009 at 10:55:33AM -0700, Luis R. Rodriguez wrote:
> > > +After a driver has been present for one kernel release the relaxed rules for
> > > +it during the rc-series are no longer applicable.
> > 
> > except staging drivers?
> 
> Hm, I consider staging a different chapter.

Actually, no, I've been treating drivers/staging/ under the same merge
rules at the moment as the rest of the kernel.

thanks,

greg k-h
