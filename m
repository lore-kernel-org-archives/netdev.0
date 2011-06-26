From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] net_sched: fix dequeuer fairness
Date: Sun, 26 Jun 2011 12:29:05 -0400
Message-ID: <1309105745.5134.54.camel@mojatatu>
References: <1309097254.5134.24.camel@mojatatu>
	 <1309100994.2532.35.camel@edumazet-laptop>
	 <1309102334.5134.31.camel@mojatatu>  <1309104215.5134.37.camel@mojatatu>
	 <1309105599.2532.50.camel@edumazet-laptop>
Reply-To: jhs@mojatatu.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:50058 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754477Ab1FZQ3K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jun 2011 12:29:10 -0400
Received: by iwn6 with SMTP id 6so3533553iwn.19
        for <netdev@vger.kernel.org>; Sun, 26 Jun 2011 09:29:09 -0700 (PDT)
In-Reply-To: <1309105599.2532.50.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2011-06-26 at 18:26 +0200, Eric Dumazet wrote:

> Difficult to discuss about your patch because you didnt inline it :-(

Evolution messes up with the whitespaces when i do that.

> You should remove this line in the comment
> 
> +                * 3. we've been doing it for too long.

yikes, yes. 

cheers,
jamal



