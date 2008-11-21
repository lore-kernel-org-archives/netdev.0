From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Re: pkt_sched: add DRR scheduler
Date: Fri, 21 Nov 2008 13:36:21 +0100
Message-ID: <4926AB45.2000505@trash.net>
References: <20081120113557.GA5275@ff.dom.local> <49254D42.10506@trash.net> <20081121121949.GA13892@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52106 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753768AbYKUMg3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 07:36:29 -0500
In-Reply-To: <20081121121949.GA13892@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> A small oversight:
> ----------------->
> pkt_sched: sch_drr: Fix qlen in drr_drop()
>
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Good catch, thanks.

Acked-by: Patrick McHardy <kaber@trash.net>
