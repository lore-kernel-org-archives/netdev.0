From: Matt Wilson <msw@amzn.com>
Subject: Re: [PATCH net-next] net: ena: Add a driver for Amazon Elastic
 Network Adapters (ENA)
Date: Wed, 15 Jun 2016 11:39:24 -0700
Message-ID: <20160615183924.GA19719@u54ee753d2d1854bda401.ant.amazon.com>
References: <1465807573-11293-1-git-send-email-netanel@annapurnalabs.com>
 <20160615180717.GA14049@u54ee753d2d1854bda401.ant.amazon.com>
 <20160615182231.GB14049@u54ee753d2d1854bda401.ant.amazon.com>
 <CAO+Uck_mkRmhkFedb1FsbvuEFFebhYEfYb1UqM+VGSFfKFWN0Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matt Wilson <msw@amzn.com>, netdev@vger.kernel.org,
	davem@davemloft.net, linux-kernel@vger.kernel.org,
	Zorik Machulsky <zorik@annapurnalabs.com>,
	Saeed Bishara <saeed@annapurnalabs.com>,
	Alexander Matushevsky <alex@annapurnalabs.com>,
	"Liguori, Anthony" <aliguori@amazon.com>,
	Antoine =?iso-8859-1?Q?T=E9nart?=
	<antoine.tenart@free-electrons.com>
To: Netanel Belgazal <netanel@annapurnalabs.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAO+Uck_mkRmhkFedb1FsbvuEFFebhYEfYb1UqM+VGSFfKFWN0Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 15, 2016 at 09:32:35PM +0300, Netanel Belgazal wrote:
> I removed HAVE_NETDEV_NAPI_LIST and fixed the ena print macro.
> I'll wait a bit to see if there are additional comment before I'll send the
> v2 patch.

Also, please don't top post (reply inline) and send emails as plain
text only. Have a look at [1] for how to set up a mailer like mutt
with Gmail.

--msw

[1] https://www.kernel.org/doc/Documentation/email-clients.txt

> On 15 June 2016 at 21:22, Matt Wilson <msw@amzn.com> wrote:
> 
> > On Wed, Jun 15, 2016 at 11:07:17AM -0700, Matt Wilson wrote:
> > >
> > > You also had a few typos in the email addresses on the Cc: line that
> > > I've corrected (davm@avemeloft.net -> davem@davemeloft.net,
> >
> > Argh, and of course I typo'ed the correction. -> davem@davemloft.net.
> >
> > --msw
> >
