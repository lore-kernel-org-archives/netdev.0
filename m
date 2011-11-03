From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 0/2] clean up tx_bytes accounting
Date: Thu,  3 Nov 2011 10:47:53 +0100
Message-ID: <1320313675-30749-1-git-send-email-mkl@pengutronix.de>
References: <70F6AAAFDC054F41B9994A9BCD3DF64E16FAA8E0@exch01-aklnz.MARINE.NET.INT>
Cc: kurt.van.dijck@eia.be, netdev@vger.kernel.org,
	linux-can@vger.kernel.org, Reuben.Dowle@navico.com
To: socketcan@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:42619 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754452Ab1KCJsB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2011 05:48:01 -0400
In-Reply-To: <70F6AAAFDC054F41B9994A9BCD3DF64E16FAA8E0@exch01-aklnz.MARINE.NET.INT>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

what about turning can_get_echo_skb() into a helper function which returns the number
of tx'ed bytes.

Marc
