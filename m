From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH 08/43] drivers/net/ppp*.c: fix sparse warnings: fix
	signedness
Date: Sun, 15 Feb 2009 00:29:48 +0300
Message-ID: <20090214212948.GE7648@localhost>
References: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net> <20090214211346.23489.96321.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Hannes Eder <hannes@hanneseder.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:8087 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752151AbZBNV3s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Feb 2009 16:29:48 -0500
Content-Disposition: inline
In-Reply-To: <20090214211346.23489.96321.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Hannes Eder - Sat, Feb 14, 2009 at 10:13:52PM +0100]
| Fix this sparse warnings:
|   drivers/net/ppp_generic.c:919:43: warning: incorrect type in argument 1 (different signedness)
|   drivers/net/pppoe.c:1195:43: warning: incorrect type in argument 1 (different signedness)
|   drivers/net/pppol2tp.c:2666:43: warning: incorrect type in argument 1 (different signedness)
| 
| Signed-off-by: Hannes Eder <hannes@hanneseder.net>
...

Thanks Hannes,

Acked-by: Cyrill Gorcunov <gorcunov@openvz.org>

	- Cyrill -
