From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: variables reach -1, but 0 tested
Date: Mon, 02 Feb 2009 23:18:56 -0800 (PST)
Message-ID: <20090202.231856.127177453.davem@davemloft.net>
References: <498429AE.1080404@gmail.com>
	<1233434112.5903.28.camel@desktop>
	<4985CC81.1040801@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dwalker@fifo99.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33796
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751218AbZBCHS7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2009 02:18:59 -0500
In-Reply-To: <4985CC81.1040801@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Sun, 01 Feb 2009 17:23:29 +0100

> Ok, here it is again:
> 
> while (timeout--) { ... }
> 
> timeout becomes -1 if the loop isn't ended otherwise, not 0.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>

Applied.
