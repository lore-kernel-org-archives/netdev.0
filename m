From: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH 2/7] ATM cell alignment.
Date: Thu, 10 Apr 2008 10:35:00 -0400
Message-ID: <200804101435.m3AEZ0bf008603@cmf.nrl.navy.mil>
References: <Pine.LNX.4.64.0804092259460.21022@ask.diku.dk>
Reply-To: chas3@users.sourceforge.net
Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ginger.cmf.nrl.navy.mil ([134.207.10.161]:40248 "EHLO
	ginger.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756083AbYDJPFU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2008 11:05:20 -0400
In-reply-to: <Pine.LNX.4.64.0804092259460.21022@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In message <Pine.LNX.4.64.0804092259460.21022@ask.diku.dk>,Jesper Dangaard Brou
er writes:
>+#define ATM_CELL_SIZE               53  /* ATM cell size incl. header */
>+#define ATM_CELL_PAYLOAD            48  /* ATM payload size */

these constants are already in linux/atm.h
