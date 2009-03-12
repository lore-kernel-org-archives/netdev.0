From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH] dnet: Dave DNET ethernet controller driver
Date: Thu, 12 Mar 2009 20:35:11 +0000
Message-ID: <20090312203511.GJ7854@n2100.arm.linux.org.uk>
References: <49B91A7B.7050303@weinigel.se> <20090312151211.GB24995@hmsreliant.think-freely.org> <49B93777.7030202@weinigel.se> <20090312.104345.68580544.davem@davemloft.net> <49B94BCA.6090309@weinigel.se> <20090312180638.GG14491@shareable.org> <49B95907.4010404@weinigel.se> <20090312190416.GS425@pengutronix.de> <20090312201449.95468832E8B8@gemini.denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sascha Hauer <s.hauer@pengutronix.de>,
	Christer Weinigel <christer@weinigel.se>,
	Jamie Lokier <jamie@shareable.org>,
	David Miller <davem@davemloft.net>, nhorman@tuxdriver.com,
	shemminger@vyatta.com, yanok@emcraft.com,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	dzu@denx.de, Vladimir Khusainov <vlad@emcraft.com>,
	Nick Ivanter <nick@emcraft.com>,
	Sergei Poselenov <sposelenov@emcraft.com>
To: Wolfgang Denk <wd@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:43619 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751511AbZCLUgM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2009 16:36:12 -0400
Content-Disposition: inline
In-Reply-To: <20090312201449.95468832E8B8@gemini.denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 12, 2009 at 09:14:49PM +0100, Wolfgang Denk wrote:
> Dear Sascha Hauer,
> 
> In message <20090312190416.GS425@pengutronix.de> you wrote:
> >
> > Great, but how does this help in setting the MAC address? This would
> > just move this exact discussion to the dracut or whatever mailing list,
> > but we would still be searching for a generic way to say
> > eth0addr=00:01:02:03:04:05 and I bet the arguments stay the same.
> 
> Well, PowerPC uses the device tree for such information.  As  far  as
> I've been told work is underway to extend the device tree support for
> ARM, too.

EWW.
