From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 3/4] gigaset: reduce syslog clutter
Date: Mon, 22 Feb 2010 20:32:11 -0800
Message-ID: <1266899531.9265.4.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Karsten Keil <isdn@linux-pingi.de>,
	David Miller <davem@davemloft.net>,
	Hansjoerg Lipp <hjlipp@web.de>,
	Karsten Keil <keil@b1-systems.de>,
	isdn4linux@listserv.isdn4linux.de,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Tilman Schmidt <tilman@imap.cc>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Perhaps it'd be useful to add a ethtool/netif_msg interface
and classify the messages as appropriate.
