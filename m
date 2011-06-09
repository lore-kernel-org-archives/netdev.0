From: Greg KH <greg@kroah.com>
Subject: Re: linux-next: build failure after merge of the net tree
Date: Thu, 9 Jun 2011 12:29:29 -0700
Message-ID: <20110609192929.GA12121@kroah.com>
References: <20110609145657.96fae0d0.sfr@canb.auug.org.au>
 <7CA9E653-DABC-470C-BCA6-905D6EBF9283@kroah.com>
 <20110609153904.e602b317.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"<netdev@vger.kernel.org>" <netdev@vger.kernel.org>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Alexey Dobriyan <adobriyan@gmail.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110609153904.e602b317.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 09, 2011 at 03:39:04PM +1000, Stephen Rothwell wrote:
> Hi Greg,
> 
> On Wed, 8 Jun 2011 22:17:55 -0700 Greg K-H <greg@kroah.com> wrote:
> >
> > Sorry, this is something that Linus asked for and will be going to him
> > tomorrow with the rest of the staging-linus branch.
> 
> Yeah, I remember the discussion, just not a conclusion.  At least the
> x86_64 allmodconfig builds worked before I merged the net tree, so that is
> something.
> 
> The powerpc allyesconfig build is going to be interesting :-(
> 
> You might like to check the build results at
> http://kisskb.ellerman.id.au/kisskb/branch/9/ sometime tomorrow.  Or
> point your janitors at it :-)

I don't see any failures in the staging tree in the powerpc allyesconfig
build, so all must be good :)

thanks,

greg k-h
