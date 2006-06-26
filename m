From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] make net/core/dev.c:netdev_nit static
Date: Sun, 25 Jun 2006 23:58:24 -0700 (PDT)
Message-ID: <20060625.235824.97292998.davem@davemloft.net>
References: <20060625231327.GL23314@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:20123
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751193AbWFZG6Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jun 2006 02:58:25 -0400
To: bunk@stusta.de
In-Reply-To: <20060625231327.GL23314@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>
Date: Mon, 26 Jun 2006 01:13:27 +0200

> netdev_nit can now become static.
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

Applied, thanks Adrian.
