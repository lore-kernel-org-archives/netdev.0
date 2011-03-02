From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] sched: QFQ - quick fair queue scheduler (v2)
Date: Wed, 02 Mar 2011 12:50:43 +0100
Message-ID: <4D6E2F13.4030300@trash.net>
References: <20110228171738.2cc8c9a0@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Fabio Checconi <fabio@gandalf.sssup.it>,
	Luigi Rizzo <rizzo@iet.unipi.it>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:65211 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757115Ab1CBLuq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 06:50:46 -0500
In-Reply-To: <20110228171738.2cc8c9a0@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 01.03.2011 02:17, schrieb Stephen Hemminger:
> This is an implementation of the Quick Fair Queue scheduler developed
> by Fabio Checconi. The same algorithm is already implemented in ipfw
> in FreeBSD. Fabio had an earlier version developed on Linux, I just
> cleaned it up and tested it. All bugs are mine.
> 
> This version is still experimental, do not use for production.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Looks good to me from a qdisc API POV.
