From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] make pktgen.c:get_ipsec_sa() static and non-inline
Date: Mon, 30 Jul 2007 18:04:20 -0700 (PDT)
Message-ID: <20070730.180420.77404858.davem@davemloft.net>
References: <20070729145840.GY16817@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, robert.olsson@its.uu.se,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: bunk@stusta.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49851
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757377AbXGaBE1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2007 21:04:27 -0400
In-Reply-To: <20070729145840.GY16817@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>
Date: Sun, 29 Jul 2007 16:58:40 +0200

> Non-static inline code usually doesn't makes sense.
> 
> In this case making is static and non-inline is the correct solution.
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

Applied, thanks Adrian.
