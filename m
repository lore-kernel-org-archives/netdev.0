From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH 1/4] net: mvneta: driver for Marvell Armada 370/XP
 network unit
Date: Tue, 30 Oct 2012 13:28:49 +0100
Message-ID: <20121030132849.72d18e4f@skate>
References: <1351245804-31478-1-git-send-email-thomas.petazzoni@free-electrons.com>
	<1351245804-31478-2-git-send-email-thomas.petazzoni@free-electrons.com>
	<CABMQnVLBCU-2C6DbKsXAVPanWx=oQnjE7Tpi2q5bgpYJ9SQt-A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Lennert Buytenhek <kernel@wantstofly.org>,
	Lior Amsalem <alior@marvell.com>, Andrew Lunn <andrew@lunn.ch>,
	Jason Cooper <jason@lakedaemon.net>, netdev@vger.kernel.org,
	Maen Suleiman <maen@marvell.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org
To: Nobuhiro Iwamatsu <iwamatsu@nigauri.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([88.190.12.23]:51251 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932126Ab2J3M3E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2012 08:29:04 -0400
In-Reply-To: <CABMQnVLBCU-2C6DbKsXAVPanWx=oQnjE7Tpi2q5bgpYJ9SQt-A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Nobuhiro Iwamatsu,

On Tue, 30 Oct 2012 21:07:34 +0900, Nobuhiro Iwamatsu wrote:

> I tested this driver on OpenBlocks AX3 and worked fine.

Thanks.

> I will send a patch which support DT for OpenBlocks AX3.

I was also about to prepare a patch doing that, but I was waiting for
the network driver itself to be merged, and also the basic OpenBlocks
AX3 support as well.


> Tested-by: Nobuhiro Iwamatsu <iwamatsu@nigauri.org>

Thanks!

Thomas
-- 
Thomas Petazzoni, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
