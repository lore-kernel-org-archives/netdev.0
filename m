From: Jamie Lokier <jamie@shareable.org>
Subject: Re: [PATCH] dnet: Dave DNET ethernet controller driver
Date: Thu, 12 Mar 2009 19:15:21 +0000
Message-ID: <20090312191521.GA16611@shareable.org>
References: <49B91A7B.7050303@weinigel.se> <20090312151211.GB24995@hmsreliant.think-freely.org> <49B93777.7030202@weinigel.se> <20090312.104345.68580544.davem@davemloft.net> <49B94BCA.6090309@weinigel.se> <20090312180638.GG14491@shareable.org> <49B95907.4010404@weinigel.se> <20090312190416.GS425@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Christer Weinigel <christer@weinigel.se>,
	David Miller <davem@davemloft.net>, nhorman@tuxdriver.com,
	shemminger@vyatta.com, yanok@emcraft.com,
	linux-arm-kernel@lists.arm.linux.org.uk,
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.shareable.org ([80.68.89.115]:52627 "EHLO
	mail2.shareable.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750945AbZCLTPe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2009 15:15:34 -0400
Content-Disposition: inline
In-Reply-To: <20090312190416.GS425@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sascha Hauer wrote:
> Great, but how does this help in setting the MAC address? This would
> just move this exact discussion to the dracut or whatever mailing list,
> but we would still be searching for a generic way to say
> eth0addr=00:01:02:03:04:05 and I bet the arguments stay the same.

The objection "we're not taking that because it should go in initrd"
would go away.

-- Jamie
