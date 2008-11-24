From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tokenring/3c359.c: fix allocation null check
Date: Mon, 24 Nov 2008 14:48:01 -0800 (PST)
Message-ID: <20081124.144801.234826251.davem@davemloft.net>
References: <20081123202850.372eb7cb@jirka.pirko.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, jgarzik@pobox.com,
	netdev@vger.kernel.org
To: jirka@pirko.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46718
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753556AbYKXWsB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 17:48:01 -0500
In-Reply-To: <20081123202850.372eb7cb@jirka.pirko.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jirka Pirko <jirka@pirko.cz>
Date: Sun, 23 Nov 2008 20:28:50 +0100

> Fixed type when allocating rx_ring, tx_ring was checked for null instead.
> 
> Signed-off-by: Jirka Pirko <jirka@pirko.cz>

Applied.
