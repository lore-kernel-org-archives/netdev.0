From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]iwlwifi not correctly dealing with hotunplug
Date: Tue, 13 Nov 2007 21:10:54 -0800 (PST)
Message-ID: <20071113.211054.45565962.davem@davemloft.net>
References: <200711131926.53732.oneukum@suse.de>
	<1195003854.3250.120.camel@debian.sh.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: oneukum@suse.de, linville@tuxdriver.com, netdev@vger.kernel.org,
	ipw2100-devel@lists.sourceforge.net, dcbw@redhat.com,
	linux-wireless@vger.kernel.org
To: yi.zhu@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52223
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750893AbXKNFKz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 00:10:55 -0500
In-Reply-To: <1195003854.3250.120.camel@debian.sh.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zhu Yi <yi.zhu@intel.com>
Date: Wed, 14 Nov 2007 09:30:54 +0800

> 
> On Tue, 2007-11-13 at 19:26 +0100, Oliver Neukum wrote:
> > It makes no sense to enable interrupts if a device has been unplugged.
> > In addition if in doubt IRQ_HANDLED should be returned.
> > 
> > Signed-off-by: Oliver Neukum <oneukum@suse.de>
> 
> ACK.

I've applied Olver's patch, thanks.

