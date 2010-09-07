From: David Miller <davem@davemloft.net>
Subject: Re: STMMAC: sleep inside atomic
Date: Mon, 06 Sep 2010 17:50:23 -0700 (PDT)
Message-ID: <20100906.175023.179945036.davem@davemloft.net>
References: <4C854013.70704@gmail.com>
	<20100906.130855.112605035.davem@davemloft.net>
	<4C85554B.2080800@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org
To: jirislaby@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56735
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754017Ab0IGAuF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Sep 2010 20:50:05 -0400
In-Reply-To: <4C85554B.2080800@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Slaby <jirislaby@gmail.com>
Date: Mon, 06 Sep 2010 22:55:39 +0200

> On 09/06/2010 10:08 PM, David Miller wrote:
>>> Hi, I hope you'll carbon-copy me. It's not only kmalloc, request_irq
>>> and others may sleep too.
>> 
>> Guiseppe CAVALLARO posted a patch that seems to be a working one,
>> please see his netdev posting.
> 
> I can't find it, could you send me subject of the message?

"[PATCH] stmmac: fix sleep inside atomic"
