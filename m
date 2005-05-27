From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [patch 2.6.12-rc5] tg3: add bcm5752 entry to pci.ids
Date: Fri, 27 May 2005 20:02:03 +0100
Message-ID: <20050527190203.GA7692@infradead.org>
References: <04132005193844.8410@laptop> <04132005193844.8474@laptop> <20050421165956.55bdcb14.davem@davemloft.net> <20050527184750.GB11592@tuxdriver.com> <20050527185334.GA7417@infradead.org> <20050527190000.GC11592@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@infradead.org>,
        "David S. Miller" <davem@davemloft.net>, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com, jgarzik@pobox.com, mchan@broadcom.com
Content-Disposition: inline
In-Reply-To: <20050527190000.GC11592@tuxdriver.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, May 27, 2005 at 03:00:00PM -0400, John W. Linville wrote:
> On Fri, May 27, 2005 at 07:53:35PM +0100, Christoph Hellwig wrote:
> > On Fri, May 27, 2005 at 02:47:52PM -0400, John W. Linville wrote:
> 
> > > +	1600  NetXtreme BCM5752 Gigabit Ethernet PCI Express
> > 
> > I don't think you should mention "PCI Express" here.  That can trivially
> > befound it looking at the configuration header.
> 
> I'm just following what is at pciids.sourceforge.net.  Plus, it is
> already like that for nine other IDs:
> 
>         1659  NetXtreme BCM5721 Gigabit Ethernet PCI Express
>         1677  NetXtreme BCM5751 Gigabit Ethernet PCI Express
>         167d  NetXtreme BCM5751M Gigabit Ethernet PCI Express
>         167e  NetXtreme BCM5751F Fast Ethernet PCI Express
>         169d  NetLink BCM5789 Gigabit Ethernet PCI Express
>         16dd  NetLink BCM5781 Gigabit Ethernet PCI Express
>         16f7  NetXtreme BCM5753 Gigabit Ethernet PCI Express
>         16fd  NetXtreme BCM5753M Gigabit Ethernet PCI Express
>         16fe  NetXtreme BCM5753F Fast Ethernet PCI Express
> 
> The Broadcom guys can speak-up, but I figure they know if "PCI Express"
> is appropriate for their device... :-)

ok, it should be an all or nothing.  I still think it's more than silly..
