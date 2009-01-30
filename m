From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net/skfp: if !capable(CAP_NET_ADMIN): inverted
 logic
Date: Thu, 29 Jan 2009 17:32:35 -0800 (PST)
Message-ID: <20090129.173235.119705296.davem@davemloft.net>
References: <4980B135.8040209@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55253
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756000AbZA3Bch (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 20:32:37 -0500
In-Reply-To: <4980B135.8040209@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Wed, 28 Jan 2009 20:25:41 +0100

> untested, but It seems this is likely what it should be.
> --------------------->8---------8<----------------
> fix inverted logic
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>

Good catch Roel, patch applied.
