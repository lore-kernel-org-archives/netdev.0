From: Christoph Hellwig <hch@infradead.org>
Subject: Re: ipw2100 wireless driver
Date: Tue, 10 Aug 2004 07:55:59 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040810075558.A14154@infradead.org>
References: <20040714114135.GA25175@elf.ucw.cz> <Pine.LNX.4.60.0407141947270.27995@boston.corp.fedex.com> <20040714115523.GC2269@elf.ucw.cz> <20040809201556.GB9677@louise.pinerecords.com> <Pine.LNX.4.61.0408101258130.1290@boston.corp.fedex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tomas Szepe <szepe@pinerecords.com>, Pavel Machek <pavel@suse.cz>,
        netdev@oss.sgi.com, kernel list <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Chua <jeffchua@silk.corp.fedex.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.61.0408101258130.1290@boston.corp.fedex.com>; from jeffchua@silk.corp.fedex.com on Tue, Aug 10, 2004 at 01:02:07PM +0800
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Aug 10, 2004 at 01:02:07PM +0800, Jeff Chua wrote:
> 
> On Mon, 9 Aug 2004, Tomas Szepe wrote:
> 
> > ipw2100 0.51 from ipw2100.sf.net builds using gcc-2.95.3 "out of the box."
> 
> Well, this is really good news!
> 
> I just downloaded 0.51 compiled with gcc-2.95.3 and got it working on my 
> IBM X31 with WEP. Even better, 0.51 doesn't need hostap-driver.

Btw, any vounteer for merging the hostap-based generic ieee80211_* files
from the ipw2100 driver with the hostap driver in the wireless-2.6 tree?
