From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IRDA: cnt is off by 1
Date: Thu, 12 Feb 2009 16:42:43 -0800 (PST)
Message-ID: <20090212.164243.259973873.davem@davemloft.net>
References: <49932805.7050309@gmail.com>
	<20090211202755.GA2550@ami.dom.local>
	<4993418D.5020700@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, netdev@vger.kernel.org,
	akpm@linux-foundation.org, samuel@sortiz.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48399
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758289AbZBMAmt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2009 19:42:49 -0500
In-Reply-To: <4993418D.5020700@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Wed, 11 Feb 2009 22:22:21 +0100

> If no prior break occurs, cnt reaches 101 after the loop, so we are still able
> to change speed when cnt has become 100.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>

Applied, thanks Roel.
