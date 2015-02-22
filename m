From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: repository for switch hardware info
Date: Sun, 22 Feb 2015 22:40:32 +0100
Message-ID: <20150222214032.GB16675@lunn.ch>
References: <20150222.160345.141886361578055811.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:47383 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752103AbbBVVna (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Feb 2015 16:43:30 -0500
Content-Disposition: inline
In-Reply-To: <20150222.160345.141886361578055811.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 22, 2015 at 04:03:45PM -0500, David Miller wrote:
> 
> There are various vendor switch SDKs (some opensource, some not),
> vendor switch hardware specification documents, etc. scattered all
> over the place.

Hi David

Marvell has one public datasheet:

http://www.marvell.com/switching/assets/marvell_linkstreet_88E6060_datasheet.pdf

Marvell also have reference code, which is GPL, but is the usual
vendor quality. There does not appear to be an official Marvell
location for it, but there are a few copies lying around, e.g:

https://github.com/mmilburn/marvell-switch

which was extracted from the WRT1900ac tarball of GPL sources.

      Andrew
