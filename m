From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH v7 5/7 RFC] TCPCT part 1e: implement
 socket option TCP_COOKIE_TRANSACTIONS
Date: Sun, 22 Nov 2009 16:31:12 -0800 (PST)
Message-ID: <20091122.163112.80105623.davem@davemloft.net>
References: <4B06AC2C.3070102@gmail.com>
	<20091120.092651.254794724.davem@davemloft.net>
	<4B08D967.80003@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: william.allen.simpson@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60350
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751133AbZKWAa5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Nov 2009 19:30:57 -0500
In-Reply-To: <4B08D967.80003@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: William Allen Simpson <william.allen.simpson@gmail.com>
Date: Sun, 22 Nov 2009 01:25:43 -0500

> Therefore, David, would indentation of 2 or 4 be preferable here?

It should be of the form:

	if (x &&
	    y)

or:
	if (x && y)

Fix patches, rather than complaints, for existing cases where things
do not follow this pattern are cetainly welcome.
