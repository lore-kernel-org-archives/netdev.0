From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.32-rc5-mmotm1101 - kernel BUG at net/ipv4/tcp_input.c:3707!
Date: Wed, 04 Nov 2009 23:22:49 -0800 (PST)
Message-ID: <20091104.232249.231355554.davem@davemloft.net>
References: <Pine.LNX.4.64.0911032330090.3488@melkinkari.cs.Helsinki.FI>
	<7916.1257300093@turing-police.cc.vt.edu>
	<4AF1AF28.2030106@codefidence.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Valdis.Kletnieks@vt.edu, ilpo.jarvinen@helsinki.fi,
	eric.dumazet@gmail.com, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	ori@comsleep.com
To: gilad@codefidence.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48187
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750825AbZKEHWX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2009 02:22:23 -0500
In-Reply-To: <4AF1AF28.2030106@codefidence.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gilad Ben-Yossef <gilad@codefidence.com>
Date: Wed, 04 Nov 2009 18:43:20 +0200

> Kindly try the next patch. It goes on top (in addition to) the
> previous one. This should fix the crash.

Ok, now I know that both patches need to go in, I'll apply
the other one too.

Forget about my confusion in my other reply.
