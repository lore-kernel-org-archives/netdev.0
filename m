From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/13] drivers/net: Remove redundant test
Date: Thu, 25 Dec 2008 18:04:07 -0800 (PST)
Message-ID: <20081225.180407.94213434.davem@davemloft.net>
References: <Pine.LNX.4.64.0812211637560.9555@pc-004.diku.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: julia@diku.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34499
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753018AbYLZCEF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Dec 2008 21:04:05 -0500
In-Reply-To: <Pine.LNX.4.64.0812211637560.9555@pc-004.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>
Date: Sun, 21 Dec 2008 16:38:54 +0100 (CET)

> In each case, ap is checked not to be NULL a few lines before.

Applied.
