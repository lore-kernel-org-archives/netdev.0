From: Greg KH <greg@kroah.com>
Subject: Re: linux-next: manual merge of the char-misc tree with the net-next
 tree
Date: Thu, 8 Sep 2016 12:21:15 +0200
Message-ID: <20160908102115.GA22483@kroah.com>
References: <20160905165650.180e6c89@canb.auug.org.au>
 <20160905113353.GB27586@kroah.com>
 <DM2PR0301MB07835EA7440B54BE9B27A516A0F90@DM2PR0301MB0783.namprd03.prod.outlook.com>
 <DM2PR0301MB078354E908258795044BFCFEA0F90@DM2PR0301MB0783.namprd03.prod.outlook.com>
 <BLUPR0301MB209827200D789C51EC56DA41CCF90@BLUPR0301MB2098.namprd03.prod.outlook.com>
 <20160907064712.GB31273@kroah.com>
 <BY2PR0301MB2104C50A152139E94BC3E442CCF80@BY2PR0301MB2104.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: KY Srinivasan <kys@microsoft.com>,
        Stephen Rothwell <sfr@canb.auug.org.au>,
        Arnd Bergmann <arnd@arndb.de>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>,
        "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Vitaly Kuznetsov <vkuznets@redhat.com>
To: Stephen Hemminger <sthemmin@microsoft.com>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <BY2PR0301MB2104C50A152139E94BC3E442CCF80@BY2PR0301MB2104.namprd03.prod.outlook.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 07, 2016 at 04:51:12PM +0000, Stephen Hemminger wrote:
> It isn't so much about the Pull Request, more about having a single pre-merged
> location and making sure that everyone is on the same page for testing.

I don't understand.  If you want to have a git tree, for testing in
linux-next, that's fine, but I still need/want patches in email to take
things to be merged "properly" on through to Linus for the sections of
the hv code that go through me.

thanks,

greg k-h
