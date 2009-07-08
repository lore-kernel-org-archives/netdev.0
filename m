From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pcnet_cs: add odd location support for write_asic
 function
Date: Wed, 08 Jul 2009 10:38:05 -0700 (PDT)
Message-ID: <20090708.103805.233850916.davem@davemloft.net>
References: <20090405094907.5f6a5fea.ken_kawasaki@spring.nifty.jp>
	<20090708210924.2a486a84.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ken_kawasaki@spring.nifty.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60023
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754520AbZGHRiC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2009 13:38:02 -0400
In-Reply-To: <20090708210924.2a486a84.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Date: Wed, 8 Jul 2009 21:09:24 +0900

> Signed-off-by: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>

This patch is already in the patchwork queue for networking:

	http://patchwork.ozlabs.org/patch/29462/

What is this odd address support actually needed for?  You
should have provided this information in the commit message.

That's why I haven't bothered applying the patch yet, I don't
even know what needs it.
