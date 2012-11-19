From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] net: mvneta: adjust multiline comments to net/
 style
Date: Mon, 19 Nov 2012 14:01:02 -0500 (EST)
Message-ID: <20121119.140102.642494594218015592.davem@davemloft.net>
References: <1353322834-16952-1-git-send-email-thomas.petazzoni@free-electrons.com>
	<1353322834-16952-4-git-send-email-thomas.petazzoni@free-electrons.com>
	<50AA2AD4.6030007@mvista.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com, jason@lakedaemon.net,
	alior@marvell.com, andrew@lunn.ch, netdev@vger.kernel.org,
	gregory.clement@free-electrons.com,
	linux-arm-kernel@lists.infradead.org
To: sshtylyov@mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60372 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754056Ab2KSTBE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 14:01:04 -0500
In-Reply-To: <50AA2AD4.6030007@mvista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sshtylyov@mvista.com>
Date: Mon, 19 Nov 2012 16:49:24 +0400

>    Why the heck you're doing this? It's the preferred style, see
>    Documentation/CodingStyle, chapter 8.

Not in the networking code, we prefer:

	/* Doing it,
	 * like this.
	 */

there.
