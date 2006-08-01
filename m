From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH dscape] d80211: Switch d80211.h to IEEE80211_ style names
Date: Tue, 1 Aug 2006 10:07:26 -0400
Message-ID: <20060801140720.GC29208@tuxdriver.com>
References: <200607270037.22384.flamingice@sourmilk.net> <20060731203113.GG10138@tuxdriver.com> <200607311351.35757.flamingice@sourmilk.net> <20060801095650.GA6831@infradead.org> <20060801122142.GB29208@tuxdriver.com> <20060801155837.4c3210aa@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>,
	Michael Wu <flamingice@sourmilk.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:2571 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1750709AbWHAOHq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2006 10:07:46 -0400
To: Jiri Benc <jbenc@suse.cz>
Content-Disposition: inline
In-Reply-To: <20060801155837.4c3210aa@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 01, 2006 at 03:58:37PM +0200, Jiri Benc wrote:

> Do you have a plan when you will merge rt2x00 patches so I can apply
> Michael's renaming patch(es) without risk of conflicts?

Working on it ~now.  I hit a snag in that Ivo's patches seem to rely on
his radio button patch, which I had ignored until now.  I'll probably
pull that in this morning (or figure-out how to not need it) and get
something pushed to wireless-dev sometime today.

John
-- 
John W. Linville
linville@tuxdriver.com
