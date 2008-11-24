From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tokenring/3c359.c: Prevent possible mem leak when open
 failed
Date: Mon, 24 Nov 2008 14:49:19 -0800 (PST)
Message-ID: <20081124.144919.41364747.davem@davemloft.net>
References: <20081123214410.44810f99@jirka.pirko.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, jgarzik@pobox.com,
	netdev@vger.kernel.org
To: jirka@pirko.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59188
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753353AbYKXWtT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 17:49:19 -0500
In-Reply-To: <20081123214410.44810f99@jirka.pirko.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jirka Pirko <jirka@pirko.cz>
Date: Sun, 23 Nov 2008 21:44:10 +0100

> Freeing previously allocated buffers in case of error.
> 
> Signed-off-by: Jirka Pirko <jirka@pirko.cz>

Applied.
