From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH dscape] d80211: Switch d80211.h to IEEE80211_ style names
Date: Tue, 1 Aug 2006 10:56:50 +0100
Message-ID: <20060801095650.GA6831@infradead.org>
References: <200607270037.22384.flamingice@sourmilk.net> <20060731203113.GG10138@tuxdriver.com> <200607311351.35757.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:27803 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S932517AbWHAJ5E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 05:57:04 -0400
To: Michael Wu <flamingice@sourmilk.net>
Content-Disposition: inline
In-Reply-To: <200607311351.35757.flamingice@sourmilk.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 31, 2006 at 01:51:31PM -0700, Michael Wu wrote:
> On Monday 31 July 2006 13:31, John W. Linville wrote:
> > As usual I'll depend on Jiri to merge d80211 stack patches, then
> > send me a pull request.  If I apply your "Switch drivers to d80211"
> > series now, that will undoutedly cause a breakage when Jiri asks me
> > to pull this later.
> >
> Yeah, there needs to be a new (and smaller) set of patches to switch drivers 
> to the d80211.h header.

NACK again.  Driver should continue to use the ieee80211.h header forever.

