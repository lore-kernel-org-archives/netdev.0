From: David Miller <davem@davemloft.net>
Subject: Re: fec: add support for PHY interface platform data
Date: Sun, 23 May 2010 23:32:24 -0700 (PDT)
Message-ID: <20100523.233224.186495044.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: baruch@tkos.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38367
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752498Ab0EXGcO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 May 2010 02:32:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch not longer applied cleanly at all.

Pretty much in every portion of the FEC driver your patch touches, the
code looks totally different in the current tree.

You'll need to respin this against Linus's current tree if you still
want me to apply it.

Thanks.
