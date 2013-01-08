From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3.8-rc] net: mvneta: fix driver operation in SMP context
Date: Mon, 07 Jan 2013 19:52:59 -0800 (PST)
Message-ID: <20130107.195259.1760491533497807910.davem@davemloft.net>
References: <1357576074-24245-1-git-send-email-thomas.petazzoni@free-electrons.com>
	<20130107164415.GI5075@titan.lakedaemon.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com, alior@marvell.com,
	andrew@lunn.ch, netdev@vger.kernel.org, maen@marvell.com,
	gregory.clement@free-electrons.com, dima@marvell.com,
	linux-arm-kernel@lists.infradead.org
To: jason@lakedaemon.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49899 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752133Ab3AHDxA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2013 22:53:00 -0500
In-Reply-To: <20130107164415.GI5075@titan.lakedaemon.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jason Cooper <jason@lakedaemon.net>
Date: Mon, 7 Jan 2013 11:44:15 -0500

> I'll assume this is going through -net, let me know if it should be
> otherwise.

It needs to be fixed up before it can be applied anywhere, see
Ben Hutchings's feedback.
