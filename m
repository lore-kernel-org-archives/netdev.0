From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH] xfrm: cache bundle lookup results in flow cache
Date: Mon, 22 Mar 2010 20:31:02 +0200
Message-ID: <4BA7B766.7070106@iki.fi>
References: <20100322013257.GA14080@gondor.apana.org.au> <20100321.183656.173864141.davem@davemloft.net> <20100322014010.GA14182@gondor.apana.org.au> <20100321.201258.184825751.davem@davemloft.net> <20100322035241.GB14457@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f216.google.com ([209.85.219.216]:37272 "EHLO
	mail-ew0-f216.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754687Ab0CVSbJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Mar 2010 14:31:09 -0400
Received: by ewy8 with SMTP id 8so303154ewy.28
        for <netdev@vger.kernel.org>; Mon, 22 Mar 2010 11:31:07 -0700 (PDT)
In-Reply-To: <20100322035241.GB14457@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Sun, Mar 21, 2010 at 08:12:58PM -0700, David Miller wrote:
>> Good point, I was misunderstanding how things work now and how
>> that would change with your proposal.
>>
>> Having multiple xfrm_dsts exist for an IPSEC route seems fine
>> to me.
> 
> Thanks for the confirmation.
> 
> Timo, let's roll along with the per-cpu xfrm_dst approach.

Okay.

- Timo

