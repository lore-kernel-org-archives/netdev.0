From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Cleanup redundant tests on unsigned
Date: Thu, 29 Oct 2009 01:40:31 -0700 (PDT)
Message-ID: <20091029.014031.110738452.davem@davemloft.net>
References: <4AE1D2D9.5000906@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39643
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753675AbZJ2IkH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 04:40:07 -0400
In-Reply-To: <4AE1D2D9.5000906@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Fri, 23 Oct 2009 17:59:21 +0200

> optlen is unsigned so the `< 0' test is never true.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>

Applied.
