From: Patrick McHardy <kaber@trash.net>
Subject: Re: BUG: warning at net/core/dev.c:1171/skb_checksum_help() 2.6.18-rc3
Date: Tue, 01 Aug 2006 09:22:04 +0200
Message-ID: <44CF011C.8040305@trash.net>
References: <44CDDDF7.70004@trash.net>	<20060731113050.GA25972@gondor.apana.org.au>	<44CE4DCA.8000609@trash.net> <20060801.000059.57444384.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37865 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S932571AbWHAHWF
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 03:22:05 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060801.000059.57444384.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> I'm going to kill the warning for 2.6.18, using the patch below.
> We can queue up Patrick's changes for 2.6.19, just give me the
> word and I'll apply it to net-2.6.19


Besides the problem I mentioned in the mail I just wrote everything
looks good so far. I'll probably send you the final version sometimes
today.
