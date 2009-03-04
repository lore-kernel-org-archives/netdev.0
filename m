From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pcmcia: worklimit reaches -1
Date: Wed, 04 Mar 2009 00:06:24 -0800 (PST)
Message-ID: <20090304.000624.11606088.davem@davemloft.net>
References: <49A538EB.8080008@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-pcmcia@lists.infradead.org,
	akpm@linux-foundation.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42506
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753079AbZCDIGj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2009 03:06:39 -0500
In-Reply-To: <49A538EB.8080008@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Wed, 25 Feb 2009 13:26:19 +0100

> with while (--worklimit >= 0); worklimit reaches -1 after the loop. In
> 3c589_cs.c this caused a warning not to be printed.
 ...
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>

Applied.
