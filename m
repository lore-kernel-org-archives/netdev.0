From: Jason Cooper <jason@lakedaemon.net>
Subject: Re: [PATCH 0/3] net: mvneta: fix usage as a module, and support
 QSGMII properly
Date: Wed, 23 Apr 2014 22:49:48 -0400
Message-ID: <20140424024948.GM28159@titan.lakedaemon.net>
References: <1397569821-5530-1-git-send-email-thomas.petazzoni@free-electrons.com>
 <20140421202840.789d0e24@skate>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Lior Amsalem <alior@marvell.com>, Andrew Lunn <andrew@lunn.ch>,
	George Joseph <george.joseph@fairview5.com>,
	Tawfik Bayouk <tawfik@marvell.com>, netdev@vger.kernel.org,
	Alexander Reuter <Alexander.Reuter@gmx.net>, arno@natisbad.org,
	Willy Tarreau <w@1wt.eu>, Nadav Haklai <nadavh@marvell.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Dmitri Epshtein <dima@marvell.com>,
	linux-arm-kernel@lists.infradead.org,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mho-02-ewr.mailhop.org ([204.13.248.72]:39761 "EHLO
	mho-02-ewr.mailhop.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751614AbaDXCuW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 22:50:22 -0400
Content-Disposition: inline
In-Reply-To: <20140421202840.789d0e24@skate>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 21, 2014 at 08:28:40PM +0200, Thomas Petazzoni wrote:
> Jason,
> 
> Would it be possible to get PATCH 3/3 merged into 3.15-rc in the not
> too distant future? David Miller has already sent PATCH 1/3 and PATCH
> 2/3, and they are part of the just released -rc2. However, the Device
> Tree fix for Armada XP GP QSGMII usage is missing.

oops, looks like I missed that one.  I'll queue it up.

thx,

Jason.
