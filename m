From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] powerpc/fs_enet: Add missing irq free in error path.
Date: Wed, 14 Jan 2009 20:44:07 -0800 (PST)
Message-ID: <20090114.204407.253886327.davem@davemloft.net>
References: <1D4ED273-13FB-4D2F-82B1-89D2F6F0B9A1@kernel.crashing.org>
	<490636B4.2010202@consentry.com>
	<606FE12E-797E-4C0C-8FA7-5C162BD959A9@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	mditto@consentry.com
To: galak@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40753
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755875AbZAOEoG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 23:44:06 -0500
In-Reply-To: <606FE12E-797E-4C0C-8FA7-5C162BD959A9@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kumar Gala <galak@kernel.crashing.org>
Date: Tue, 13 Jan 2009 10:28:15 -0600

> 
> On Oct 27, 2008, at 4:46 PM, Mike Ditto wrote:
> 
> > If something goes wrong attaching to phy driver, we weren't freeing
> > the IRQ.
> >
> > Signed-off-by: Mike Ditto <mditto@consentry.com>
 ...
> This seems to have gotten lost in the shuffle.  Can you please apply.

The netdev patchwork never saw it for some reason.

Applied, thanks.
