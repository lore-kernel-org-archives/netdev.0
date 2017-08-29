From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 0/4] irda: move it to drivers/staging so we can delete it
Date: Tue, 29 Aug 2017 07:06:43 +0200
Message-ID: <20170829050643.GA30988@kroah.com>
References: <20170827150334.32495-1-gregkh@linuxfoundation.org>
 <20170828.164208.1908438929113102094.davem@davemloft.net>
 <1503963967.2040.14.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org, samuel@sortiz.org,
 David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <1503963967.2040.14.camel@perches.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

On Mon, Aug 28, 2017 at 04:46:07PM -0700, Joe Perches wrote:
> On Mon, 2017-08-28 at 16:42 -0700, David Miller wrote:
> > From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> > Date: Sun, 27 Aug 2017 17:03:30 +0200
> > =

> > > The IRDA code has long been obsolete and broken.=A0 So, to keep people
> > > from trying to use it, and to prevent people from having to maintain =
it,
> > > let's move it to drivers/staging/ so that we can delete it entirely f=
rom
> > > the kernel in a few releases.
> > =

> > No objection, I'll apply this to net-next, thanks Greg.
> =

> Still needs an update to MAINTAINERS.

Oops, forgot those directories, will send a follow-on patch for that.

greg k-h
