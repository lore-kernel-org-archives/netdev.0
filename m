From: Jamie Lokier <jamie@shareable.org>
Subject: Re: [PATCH] dnet: Dave DNET ethernet controller driver
Date: Thu, 12 Mar 2009 18:06:38 +0000
Message-ID: <20090312180638.GG14491@shareable.org>
References: <49B91A7B.7050303@weinigel.se> <20090312151211.GB24995@hmsreliant.think-freely.org> <49B93777.7030202@weinigel.se> <20090312.104345.68580544.davem@davemloft.net> <49B94BCA.6090309@weinigel.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, nhorman@tuxdriver.com,
	shemminger@vyatta.com, s.hauer@pengutronix.de, yanok@emcraft.com,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	wd@denx.de, dzu@denx.de
To: Christer Weinigel <christer@weinigel.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.shareable.org ([80.68.89.115]:33727 "EHLO
	mail2.shareable.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754074AbZCLSHA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2009 14:07:00 -0400
Content-Disposition: inline
In-Reply-To: <49B94BCA.6090309@weinigel.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christer Weinigel wrote:
> David Miller wrote:
> > You can start with the debian installer, that's probably the
> > easiest to hack on and extend.
> > 
> > Or you can just continue to list excuses, that might be easier.
> 
> Or I can keep patching the drivers, that's even easier.  No it's not 
> something I expect to see in the official kernel, but who cares, I 
> always have loads of debug patches that won't get into the official 
> kernel either.  Keep the status quo.

Yes.  Patching your own initrd or your own modified Debian initrd is
_also_ not in the official trees, so I can't see any reason why
anybody would follow Dave's suggestion.  Much more work, different
private tree, same behaviour, probably more bloated, probably Debian's
initrd doesn't work on nommu anyway.

However there was some attempt to get a reference initrd build into
the kernel.  Did that go anywhere?  It would actually be good to use
that if it exists.

-- Jamie
