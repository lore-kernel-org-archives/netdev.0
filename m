From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ax25: proc uid file misses header
Date: Mon, 20 Apr 2009 02:15:20 -0700 (PDT)
Message-ID: <20090420.021520.99526958.davem@davemloft.net>
References: <20090417141928.15105.59684.stgit@t61.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: alan@lxorguk.ukuu.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48372
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751183AbZDTJP2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2009 05:15:28 -0400
In-Reply-To: <20090417141928.15105.59684.stgit@t61.ukuu.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Date: Fri, 17 Apr 2009 15:19:36 +0100

> This has been broken for a while. I happened to catch it testing because one
> app "knew" that the top line of the calls data was the policy line and got
> confused.
> 
> Put the header back.
> 
> Signed-off-by: Alan Cox <alan@lxorguk.ukuu.org.uk>

Applied, thanks.

I had to fixup some trailing whitespace bits, however.
