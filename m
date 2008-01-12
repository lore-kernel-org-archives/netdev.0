From: Eugene Surovegin <ebs@ebshome.net>
Subject: Re: [PATCH] ibm_newemac: Increase number of default rx-/tx-buffers
Date: Sat, 12 Jan 2008 01:08:33 -0800
Message-ID: <20080112090833.GA29314@gate.ebshome.net>
References: <1199526609-12290-1-git-send-email-sr@denx.de> <20080111174822.GB17240@gate.ebshome.net> <1200089457.6896.65.camel@pasglop> <200801120826.53091.sr@denx.de> <1200124644.6896.99.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stefan Roese <sr@denx.de>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.ebshome.net ([208.106.21.240]:49211 "EHLO gate.ebshome.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751746AbYALJIf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Jan 2008 04:08:35 -0500
Content-Disposition: inline
In-Reply-To: <1200124644.6896.99.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 12, 2008 at 06:57:24PM +1100, Benjamin Herrenschmidt wrote:
> 
> On Sat, 2008-01-12 at 08:26 +0100, Stefan Roese wrote:
> > 
> > We shouldn't make it too complicated. We can always select different
> > settings 
> > in the defconfig file. My thinking here is to better wast a little
> > memory 
> > with a potential performance improvement. Just me 0.02$
> 
> If it gets really critical, then we can move those settings to the
> device-tree.

Come on guys, it's not that critical. I guess I just don't trust a 
certain company :)

-- 
Eugene

