From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atm: Cleanup redundant tests on unsigned
Date: Thu, 29 Oct 2009 01:40:36 -0700 (PDT)
Message-ID: <20091029.014036.204247048.davem@davemloft.net>
References: <4AE1D553.8010406@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39647
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753705AbZJ2IkN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 04:40:13 -0400
In-Reply-To: <4AE1D553.8010406@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Fri, 23 Oct 2009 18:09:55 +0200

> The variables are unsigned so the `< 0' test always fails, the
> other part of the test catches wrapped values.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>

Applied.
