From: Christoph Hellwig <hch@infradead.org>
Subject: Re: A new driver for Broadcom bcm5706
Date: Fri, 27 May 2005 18:15:32 +0100
Message-ID: <20050527171532.GA5715@infradead.org>
References: <1116609329.31523.16.camel@rh4> <20050527074115.GA28208@infradead.org> <1117209503.4584.11.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>, davem@davemloft.net,
        jgarzik@redhat.com, netdev@oss.sgi.com, ffan@broadcom.com,
        lusinsky@broadcom.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Chan <mchan@broadcom.com>
Content-Disposition: inline
In-Reply-To: <1117209503.4584.11.camel@rh4>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, May 27, 2005 at 08:58:23AM -0700, Michael Chan wrote:
> > These defintions overlap older 10MB/s defintions.  I don't think the number
> > space is scare enough to need this hack.  If we absolutely want to keep it
> > you should at least add some big comments explaining it.
> > 
> > 
> Yes they do. But these overlapping bit definitions are defined by the
> 802.3 standard for 1000Base-X. These are not Broadcom proprietary
> definitions.

Ok, makes a lot of sense.  Now just mention that in a nice comment in
ethtool.h :)
