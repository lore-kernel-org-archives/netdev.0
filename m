From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: jumbo frames and memory fragmentation
Date: Mon, 17 Jul 2006 11:16:19 -0600
Message-ID: <44BBC5E3.60008@nortel.com>
References: <E1G104c-0007qF-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zcars04e.nortel.com ([47.129.242.56]:28346 "EHLO
	zcars04e.nortel.com") by vger.kernel.org with ESMTP
	id S1751073AbWGQRQ3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Jul 2006 13:16:29 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1G104c-0007qF-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> Chris Friesen <cfriesen@nortel.com> wrote:

>>Looking at the page-splitting code, it says "82571 and greater support 
>>packet-split...".  We're running the 82546GB device.  Looks like it 
>>won't help me.
> 
> 
> Well, time to fork out for a new card then :)

I wish.  This is an embedded ATCA board.  I'm not going to get a respin 
just because it doesn't deal well with jumbo frames.

Chris
