From: Jiri Slaby <jirislaby@gmail.com>
Subject: Re: STMMAC: sleep inside atomic
Date: Mon, 06 Sep 2010 22:55:39 +0200
Message-ID: <4C85554B.2080800@gmail.com>
References: <4C8231E8.5090001@gmail.com>	<4C84B8A8.5080503@st.com>	<4C854013.70704@gmail.com> <20100906.130855.112605035.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:50164 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751669Ab0IFUzo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Sep 2010 16:55:44 -0400
Received: by fxm13 with SMTP id 13so2651665fxm.19
        for <netdev@vger.kernel.org>; Mon, 06 Sep 2010 13:55:43 -0700 (PDT)
In-Reply-To: <20100906.130855.112605035.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/06/2010 10:08 PM, David Miller wrote:
>> Hi, I hope you'll carbon-copy me. It's not only kmalloc, request_irq
>> and others may sleep too.
> 
> Guiseppe CAVALLARO posted a patch that seems to be a working one,
> please see his netdev posting.

I can't find it, could you send me subject of the message?

-- 
js
