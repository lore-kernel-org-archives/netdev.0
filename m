From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH - RFC] [1/5] 64-bit network statistics - generic net
Date: 06 Jul 2003 08:27:14 +0100
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <1057476433.700.2.camel@dhcp22.swansea.linux.org.uk>
References: <E19YtAq-0006Xf-00@calista.inka.de>
	 <200307051637.52252.jeffpc@optonline.net> <3F0737D1.5090109@pobox.com>
	 <3F0745EC.1060204@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Jeff Sipek <jeffpc@optonline.net>,
	Bernd Eckenfels <ecki@calista.eckenfels.6bone.ka-ip.net.sgi.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@digeo.com>,
	Dave Jones <davej@codemonkey.org.uk>,
	Linus Torvalds <torvalds@osdl.org>, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3F0745EC.1060204@candelatech.com>
List-Id: netdev.vger.kernel.org

On Sad, 2003-07-05 at 22:41, Ben Greear wrote:
> Untill the net-stats are 64-bit on 32-bit systems, we will need some
> way to know if they have wrapped or not when reading from nettool
> and getting 64-bit numbers.

iptables

Collecting the data on a need to know basis 8)
