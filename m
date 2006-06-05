From: Andrew Morton <akpm@osdl.org>
Subject: Re: wireless (was Re: 2.6.18 -mm merge plans)
Date: Sun, 4 Jun 2006 18:15:15 -0700
Message-ID: <20060604181515.8faa8fcf.akpm@osdl.org>
References: <20060604135011.decdc7c9.akpm@osdl.org>
	<20060605010636.GB17361@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linville@tuxdriver.com, Denis Vlasenko <vda@ilport.com.ua>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:44180 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932363AbWFEBPi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jun 2006 21:15:38 -0400
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <20060605010636.GB17361@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 4 Jun 2006 21:06:36 -0400
Jeff Garzik <jeff@garzik.org> wrote:

> On Sun, Jun 04, 2006 at 01:50:11PM -0700, Andrew Morton wrote:
> > acx1xx-wireless-driver.patch
> > fix-tiacx-on-alpha.patch
> > tiacx-fix-attribute-packed-warnings.patch
> > tiacx-pci-build-fix.patch
> > tiacx-ia64-fix.patch
> > 
> >   It is about time we did something with this large and presumably useful
> >   wireless driver.
> 
> I've never had technical objections to merging this, just AFAIK it had a
> highly questionable origin, namely being reverse-engineered in a
> non-clean-room environment that might leave Linux legally vulnerable.

I never knew that.

<reads changelog>
<reads website>
<reads wiki>

I still don't know that.  Denis, do you know the details?

> If we can clear that hurdle, by all means pass it on to John Linville
> and get it moving towards upstream.

OK, thanks.
