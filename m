From: Pavel Machek <pavel@suse.cz>
Subject: Re: ipw2100 wireless driver
Date: Tue, 10 Aug 2004 12:16:40 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040810101640.GF9034@atrey.karlin.mff.cuni.cz>
References: <20040714114135.GA25175@elf.ucw.cz> <Pine.LNX.4.60.0407141947270.27995@boston.corp.fedex.com> <20040714115523.GC2269@elf.ucw.cz> <20040809201556.GB9677@louise.pinerecords.com> <Pine.LNX.4.61.0408101258130.1290@boston.corp.fedex.com> <20040810075558.A14154@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@infradead.org>,
        Jeff Chua <jeffchua@silk.corp.fedex.com>,
        Tomas Szepe <szepe@pinerecords.com>, netdev@oss.sgi.com,
        kernel list <linux-kernel@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20040810075558.A14154@infradead.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi!

> > > ipw2100 0.51 from ipw2100.sf.net builds using gcc-2.95.3 "out of the box."
> > 
> > Well, this is really good news!
> > 
> > I just downloaded 0.51 compiled with gcc-2.95.3 and got it working on my 
> > IBM X31 with WEP. Even better, 0.51 doesn't need hostap-driver.
> 
> Btw, any vounteer for merging the hostap-based generic ieee80211_* files
> from the ipw2100 driver with the hostap driver in the wireless-2.6 tree?

I know very little about wireless-2.6 tree (where to get it without
bitkeeper?), but...

task is to take ipw2100 driver, drop ieee80211_* files from it, and
make it work with ieee80211* files from wireless-2.6?

								Pavel
-- 
Horseback riding is like software...
...vgf orggre jura vgf serr.
