From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fec: init maximum receive buffer size for ring1
 and ring2
Date: Mon, 24 Nov 2014 15:22:50 -0500 (EST)
Message-ID: <20141124.152250.380142287256307570.davem@davemloft.net>
References: <1416734586-26634-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com,
	stephen@networkplumber.org, festevam@gmail.com
To: b38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52956 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750931AbaKXUWy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2014 15:22:54 -0500
In-Reply-To: <1416734586-26634-1-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fugang Duan <b38611@freescale.com>
Date: Sun, 23 Nov 2014 17:23:06 +0800

> i.MX6SX fec support three rx ring1, the current driver lost to init
> ring1 and ring2 maximum receive buffer size, that cause receving
> frame date length error. The driver reports "rcv is not +last" error
> log in user case.
> 
> Signed-off-by: Fugang Duan <B38611@freescale.com>

This patch does not apply to the 'net' tree, although it does
apply cleanly to the net-next tree.

Determining which tree a patch is for is not my job, it is your's.

Therefore you must always explicitly state what tree your patch
is intended to be added to, by starting your Subject line
with "[PATCH net] " or "[PATCH net-next] ".

I've applied this, but next time I will just ask you to properly
submit the patch instead.
