From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tokenring/3c359.c: Fix error message when allocating
 tx_ring
Date: Mon, 24 Nov 2008 14:48:31 -0800 (PST)
Message-ID: <20081124.144831.211073044.davem@davemloft.net>
References: <20081123212222.45121ffe@jirka.pirko.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, jgarzik@pobox.com,
	netdev@vger.kernel.org
To: jirka@pirko.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46722
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753563AbYKXWsc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 17:48:32 -0500
In-Reply-To: <20081123212222.45121ffe@jirka.pirko.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jirka Pirko <jirka@pirko.cz>
Date: Sun, 23 Nov 2008 21:22:22 +0100

> Pointed out by Joe Perches. Error message after tx_ring allocation check was
> wrong.
> 
> Signed-off-by: Jirka Pirko <jirka@jirka.pirko.cz>

Applied.
