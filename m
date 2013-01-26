From: Luciano Coelho <coelho@ti.com>
Subject: Re: brcm WARN() on v3.7.2
Date: Sat, 26 Jan 2013 17:14:34 +0200
Message-ID: <1359213274.6252.257.camel@cumari.coelho.fi>
References: <20130125202355.GA4846@arwen.pp.htv.fi>
	 <5103B595.8060805@broadcom.com> <20130126125622.GA9542@arwen.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Arend van Spriel <arend@broadcom.com>,
	Pieter-Paul Giesberts <pieterpg@broadcom.com>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	<linux-wireless@vger.kernel.org>,
	<brcm80211-dev-list@broadcom.com>, <netdev@vger.kernel.org>
To: <balbi@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:49795 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750990Ab3AZPPe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Jan 2013 10:15:34 -0500
In-Reply-To: <20130126125622.GA9542@arwen.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-01-26 at 14:56 +0200, Felipe Balbi wrote:
> Hi,
> 
> On Sat, Jan 26, 2013 at 11:53:09AM +0100, Arend van Spriel wrote:
> > On 01/25/2013 09:23 PM, Felipe Balbi wrote:
> > > Hi folks,
> > > 
> > > I'm running Fedora 18 with v3.7.2 on her MacBookAir 11" and it
> > > turns out that brcm is acting out, see below full dmesg. Any tips ?
> > > Is this fixed already ?
> > 
> > Thanks, Felipe
> > 
> > The warning itself means flush timed out, ie. not all outstanding
> > packets could be transmitted. It does not necessarily mean the driver
> > is failing. So do you have any connectivity issues after the warning
> > has occurred?
> 
> not really, just thought I'd mention it ;-)

If the warning is benign, maybe it shouldn't be a warning at all?

--
Luca.
