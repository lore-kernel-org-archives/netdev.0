From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 0/4] irda: move it to drivers/staging so we can delete it
Date: Sun, 27 Aug 2017 18:13:07 +0200
Message-ID: <20170827161307.GA3528@kroah.com>
References: <20170827150334.32495-1-gregkh@linuxfoundation.org>
 <1503848143.12569.48.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org, samuel@sortiz.org,
 davem@davemloft.net, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <1503848143.12569.48.camel@perches.com>
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

On Sun, Aug 27, 2017 at 08:35:43AM -0700, Joe Perches wrote:
> On Sun, 2017-08-27 at 17:03 +0200, Greg Kroah-Hartman wrote:
> > The IRDA code has long been obsolete and broken.  So, to keep people
> > from trying to use it, and to prevent people from having to maintain it,
> > let's move it to drivers/staging/ so that we can delete it entirely from
> > the kernel in a few releases.
> 
> MAINTAINERS should be updated as well.
> 
> It'd probably be nice to try to get an email to
> the irda mailing list too if it still works.

As get_maintainer.pl didn't show it, odds are it doesn't...
