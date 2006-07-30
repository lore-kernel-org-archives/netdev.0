From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix memory leak in
 net/ipv4/tcp_probe.c::tcpprobe_read()
Date: Sun, 30 Jul 2006 15:56:40 -0700 (PDT)
Message-ID: <20060730.155640.10246145.davem@davemloft.net>
References: <20060730142922.7c1d4f7d@localhost.localdomain>
	<Pine.LNX.4.64.0607301747170.26424@d.namei>
	<9a8748490607301451j21589110ifd8677f328b7eba6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, shemminger@osdl.org, kuznet@ms2.inr.ac.ru,
	yoshfuji@linux-ipv6.org, pekkas@netcore.fi, kaber@coreworks.de,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:58261
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964781AbWG3W43 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Jul 2006 18:56:29 -0400
To: jesper.juhl@gmail.com
In-Reply-To: <9a8748490607301451j21589110ifd8677f328b7eba6@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Jesper Juhl" <jesper.juhl@gmail.com>
Date: Sun, 30 Jul 2006 23:51:20 +0200

> Looks ok to me.

I've applied James's version of the fix, thanks everyone.
